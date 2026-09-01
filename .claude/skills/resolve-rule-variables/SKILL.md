---
name: resolve-rule-variables
description: Resolve XCCDF variable selections for a set of rules. Looks up which variables each rule depends on, reads their .var files, and guides the author to select a value key for each variable. Returns a list of var_name=key selections ready to add to a control file's rules list.
---

# Resolve Rule Variables

Given a product and a list of rule IDs that have just been selected for a control mapping, determine which XCCDF variables each rule depends on and interactively collect a value selection for each.

This skill is a sub-skill called by other skills (e.g., `assess-nist-control`) after rule selection. It can also be invoked directly when an author wants to inspect or change variable selections for rules already in a control file.

**Arguments**: `$ARGUMENTS` — format: `<product> <rule_id> [<rule_id> ...] [--cis-vars <var=key> [...]]`

Examples:
- Used as a sub-skill after rule selection in `assess-nist-control` Phase 3
- `/resolve-rule-variables rhel9 accounts_password_pam_dcredit accounts_password_pam_minlen`
- `/resolve-rule-variables rhel9 accounts_tmout --cis-vars var_accounts_tmout=600`

The `--cis-vars` flag passes pre-existing variable selections from CIS mappings (or other sources) as
default suggestions. Each entry is `var_name=key` matching the `.var` file option key.

## Phase 1: Load Variable Mapping

1. **Parse arguments**: Extract `product` and `rule_ids` from `$ARGUMENTS`. Also extract any `--cis-vars` entries (format: `var_name=key`).

2. **Check the mapping file**:
   ```bash
   ls build/$PRODUCT/rule_variable_mapping.json
   ```
   If the file does not exist:
   > **Note**: `build/<product>/rule_variable_mapping.json` not found. Build the product first to enable automatic variable detection:
   > ```
   > ./build_product <product> -d
   > ```
   > Proceeding without variable resolution. Add variable selections manually as `var_name=key` entries in the rules list if needed.

   Stop and return no selections if the file is missing.

3. **Look up variables for each rule**:
   ```bash
   python3 -c "
   import json, sys, os, glob

   product = sys.argv[1]
   rule_ids = sys.argv[2:]

   with open(f'build/{product}/rule_variable_mapping.json') as f:
       rule_var_map = json.load(f)

   # Collect all variables across the selected rules, deduplicating
   seen_vars = {}
   for rule_id in rule_ids:
       for var_name in rule_var_map.get(rule_id, []):
           if var_name not in seen_vars:
               seen_vars[var_name] = []
           seen_vars[var_name].append(rule_id)

   # For each variable, find the .var file and read options
   result = {}
   for var_name, used_by in seen_vars.items():
       var_files = (glob.glob(f'linux_os/**/{var_name}.var', recursive=True) +
                    glob.glob(f'shared/**/{var_name}.var', recursive=True) +
                    glob.glob(f'applications/**/{var_name}.var', recursive=True))
       if not var_files:
           result[var_name] = {'title': var_name, 'type': 'unknown', 'options': {}, 'used_by': used_by}
           continue
       import yaml
       with open(var_files[0]) as f:
           var_data = yaml.safe_load(f)
       result[var_name] = {
           'title': var_data.get('title', var_name),
           'type': var_data.get('type', 'string'),
           'options': var_data.get('options', {}),
           'used_by': used_by,
       }

   print(json.dumps(result, indent=2))
   " "$PRODUCT" $RULE_IDS
   ```

   If no variables are found for any of the rules, output an empty `{}` and stop — no variable selections needed. Report: "No variable dependencies found for the selected rules."

## Phase 2: Present Variable Selection

For each variable found in Phase 1 (process in alphabetical order):

1. **Determine the default key**: The default key is the key named `"default"` in the options dict. If no key is named `"default"`, look for the key whose value matches the majority/common case. Note the default value for display.

2. **Check for a CIS pre-selection**: If `--cis-vars` included `{var_name}=<key>`, pre-mark that option as the suggested default in the question description.

3. **Ask via `AskUserQuestion`**:
   - Question: `"Select value for \`{var_name}\` — {title}"`
   - Description on the question itself: `"Used by: {rule_id1}, {rule_id2}..."`
   - Options (limit to 4 total including the "Use default" option; if more keys exist, show the most semantically meaningful ones):

     For each key in `options` (up to 3 non-default keys):
     - `label`: the key string (e.g., `1`, `15_min`, `never`)
     - `description`: `"actual value: {value}"` — add `"(CIS suggested)"` if this key matches the `--cis-vars` selection, or `"(Default)"` if this key is the default key

     Always add a final option:
     - `label`: `"Use default (omit variable)"`
     - `description`: `"actual value: {default_value} — variable omitted from rules list, scanner uses the .var file default automatically"`

   **Example** for `var_password_pam_dcredit` with `options: {"0": "0", 1: -1, 2: -2, default: -1}`:
   ```
   label: "1"         description: "actual value: -1 (CIS suggested)"
   label: "2"         description: "actual value: -2"
   label: "0"         description: "actual value: 0"
   label: "Use default (omit variable)"  description: "actual value: -1 — variable omitted from rules list, scanner uses the .var file default automatically"
   ```
   → If key `1` chosen: written as `var_password_pam_dcredit=1`
   → If "Use default" chosen: variable NOT added to the rules list

4. **Record the selection**:
   - If a key was chosen: add `{var_name}={key}` to the output selections list
   - If "Use default" was chosen: do not add anything for this variable

## Phase 3: Report Selections

After all variables are processed, display a summary:

```
### Variable Selections

| Variable | Key | Actual Value | Status |
|----------|-----|--------------|--------|
| var_password_pam_dcredit | 1 | -1 | selected |
| var_accounts_tmout | default | 900 | omitted (using .var default) |
```

Return the selections as a list of `var_name=key` entries. These are ready to be included in the control file's `rules:` list alongside the rule IDs.

## Important Notes

- **Key, not value**: The `rules:` list stores the **key** from the `.var` file's `options` dict — not the actual value the key resolves to. `var_password_pam_dcredit=1` means key `1`, which resolves to actual value `-1`.
- **Deduplicate shared variables**: If two rules both use `var_accounts_tmout`, ask for the value once and apply it once to the rules list.
- **Variable is mandatory if a rule uses it**: Do not finalize a mapping without a variable selection when `rule_variable_mapping.json` shows the rule requires one. A rule written without its variable produces an incomplete control mapping.
- **Planned migration**: Variable selections are currently written inline in control files alongside rule IDs. The long-term plan is to extract all variable selections into a dedicated per-product file so authors can review and customize values in one place. Until that migration lands, continue writing `var_name=key` inline.

## Error Handling

- **`rule_variable_mapping.json` missing**: Stop and report — build the product first.
- **`.var` file not found for a variable**: Ask the author to enter the key manually via `AskUserQuestion` with an "Other" option. Show the variable name and note the `.var` file was not found.
- **Rule not in `rule_variable_mapping.json`**: The rule either has no XCCDF variables or was not present in the last build. Treat as having no variables — no warning.
- **Options dict is empty**: Show the variable name as informational. Offer "Use default (omit variable)" as the only option.
