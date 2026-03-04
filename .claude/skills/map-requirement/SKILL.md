---
name: map-requirement
description: Map rules to a single control file requirement using cross-framework analysis and rule search.
---

# Map Requirement

Map rules to a single requirement in a control file. This is the atomic unit of the mapping workflow — it finds candidate rules, presents them to the author, and writes the selection back to the control file.

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

**Without MCP server**: Cross-framework similarity search is unavailable. Candidate rules will be found by keyword search only, which may miss semantically similar but differently-worded requirements.

**Arguments**: $ARGUMENTS — format: `<control_id> <requirement_id> --product <product_id> [--policy <path>]`

Examples:
- `/map-requirement anssi R3 --product rhel9`
- `/map-requirement srg_gpos SRG-OS-000001-GPOS-00001 --product rhel10`
- `/map-requirement hipaa 164.312(a)(1) --product rhel9`
- `/map-requirement anssi R34 --product rhel9 --policy security_policies/anssi_2.md`

## Phase 1: Parse and Validate

1. **Parse arguments**: Extract `control_id`, `requirement_id`, `--product` flag, and optional `--policy` flag from `$ARGUMENTS`.

2. **If no `--product` specified**, ask the user via `AskUserQuestion`:
   - "Which product are you mapping rules for?"
   - Options: "rhel9", "rhel10", "rhel8", "fedora" + Other

3. **Check build artifacts**: Call `mcp__content-mcp__list_built_products`.
   - If the target product is NOT in the built list, ask the user via `AskUserQuestion`:
     - "Product '{product}' has not been built yet. Rule search works best with build artifacts (expanded Jinja templates). Build it now?"
     - Options:
       - "Yes, build now (Recommended)" — description: "Runs `/build-product {product} --datastream-only` before starting the mapping session"
       - "No, continue without build" — description: "Rule search will use raw source files, which may miss some rules due to Jinja template parsing errors"
   - If user chooses to build, invoke the `build-product` skill: `Skill(skill="build-product", args="{product} --datastream-only")`. Wait for the build to complete before continuing.
   - **Fallback**: Check if `build/{product}/rules/` directory exists. If not, offer the build prompt above.

4. **Load the requirement**: Call `mcp__content-mcp__get_control_details` with `control_id`.
   - If control not found, call `mcp__content-mcp__list_controls` and show options.
   - Find the requirement matching `requirement_id` in the controls list.
   - If requirement not found, list available requirement IDs and ask user to pick.
   - **Fallback**: Read the control YAML directly from `controls/<control_id>.yml` or `products/<product>/controls/<control_id>.yml`. If the file has `controls_dir:`, read individual requirement files from that directory. To list controls, run `ls controls/*.yml` and `ls products/*/controls/*.yml`.

5. **Display the requirement**:
   ```
   ## Requirement: {requirement_id}
   **Title**: {title}
   **Description**: {description}
   **Current status**: {status}
   **Current rules**: {rules or "none"}
   ```

6. **If no `--policy` specified**, show a tip:
   > **Tip**: Pass `--policy <path>` to enrich mapping with the original security policy text (PDF, Markdown, HTML). This improves cross-framework matching accuracy.

## Phase 1.5: Policy Enrichment (if `--policy` provided)

If `--policy` was specified:

1. **Infer document type** from the file extension:
   - `.md` → `markdown`
   - `.pdf` → `pdf`
   - `.html` → `html`
   - Otherwise → `text`

2. **Call `mcp__content-mcp__parse_policy_document`** with:
   - `source`: the policy path
   - `document_type`: inferred from extension
   - `requirement_id`: the requirement ID from Phase 1
   - **Fallback**: For markdown/text files, read the file directly and search for the requirement ID. For PDF files, inform the user that PDF parsing requires the MCP server.

3. **If sections returned**, display the policy context:
   ```
   ### Policy Context (from {policy_path})
   **{section_title}**
   {section_content}
   {subsection contents...}
   ```

4. **Store the combined section text** as `policy_text` for use in Phase 2.

## Phase 2: Find Candidate Rules

Execute steps 2a-2c to build a candidate list from multiple sources.

### Step 2a: Cross-Framework Search

Call `mcp__content-mcp__find_similar_requirements` with:
- `requirement_text`: if `policy_text` is available, use it; otherwise use the requirement's title + " " + description
- `exclude_control_id`: current control_id
- `max_results`: 10

**Fallback**: Extract 3-5 key terms from the requirement text. Use `Grep` to search for each term across `controls/*.yml` and `products/*/controls/*.yml`. Requirements matching multiple terms are likely similar. Read matched requirements to extract their `rules:` lists.

If results found, present them grouped by control framework:
```
### Similar Requirements in Other Frameworks

- [{control_id}] {requirement_id}: "{title}" → rules: {rules}
- [{control_id}] {requirement_id}: "{title}" → rules: {rules}
```

Extract the union of all rules from similar requirements as "cross-framework candidates".

### Step 2b: Rule Search in Build Artifacts

Search for candidate rules using rendered build artifacts (Jinja-expanded, product-specific):

1. Extract 3-5 key terms from the requirement title and description.
2. For each key term, call `mcp__content-mcp__search_rendered_content` with:
   - `query`: the key term
   - `product`: the target product from Phase 1
   - `limit`: 15
   - **Fallback**: If the product is not built, use `Grep` to search for key terms in `rule.yml` files under `linux_os/guide/` and `applications/`. This may miss rules with Jinja-templated descriptions.

3. Deduplicate results across all term searches. Combine with cross-framework candidates from Step 2a.

4. For each candidate rule, use `mcp__content-mcp__get_rendered_rule` (or `get_rule_details`) to read its title and description. Reason about which rules best match the requirement:
   - Look for rules whose title/description semantically matches the requirement
   - Prioritize rules that also appeared in Step 2a cross-framework results
   - Consider rule severity alignment with the requirement's intent
   - Rank candidates by relevance

5. Present the top candidates in a table:
   ```
   ### Rule Candidates

   | Rule ID | Title | Source | Reasoning |
   |---------|-------|--------|-----------|
   | {rule_id} | {title} | cross-ref / search | {why it matches} |
   ```

### Step 2c: Product Availability Check

Since `search_rendered_content` only returns rules present in the target product's build, all search results are already confirmed available. For cross-framework candidates (from Step 2a) that did NOT appear in the rendered search, call `mcp__content-mcp__get_rule_product_availability` to verify availability.
**Fallback**: For each rule, find its `rule.yml` and check the `identifiers:` section for `cce@<product>` entries. Also grep for the rule ID in `products/<target_product>/profiles/*.profile` and `products/<target_product>/controls/*.yml`.

Flag rules that are NOT available for the target product:
```
Warning: Rule '{rule_id}' has identifiers for {other_products} but NOT for {target_product}.
  May need platform/identifier additions to work for {target_product}.
```

For rules missing from the target product, use LLM judgment to assess portability:
- If the rule uses a template (`template` is not None in get_rule_details), it's likely portable
- If it has platform constraints mentioning specific products, note the constraint
- Optionally call `mcp__content-mcp__get_rule_details` with `rendered_detail=full` and `product=<a product that has it>` to read the actual OVAL/remediation and assess whether it's product-specific

## Phase 3: Author Decision

1. **Build unified candidate list**: Combine cross-framework and search candidates, deduplicated by rule_id, sorted by relevance.

2. **Present candidates** using `AskUserQuestion` with `multiSelect: true`:
   - "Select rules to map to requirement '{requirement_id}: {title}'"
   - Options: top candidates (up to 4, the AskUserQuestion limit), each with description showing source (cross-framework, search, or both) and reasoning
   - If more than 4 candidates, present top 3 + "Show more candidates"

3. **Ask about status** using a separate `AskUserQuestion`:
   - "How should this requirement be marked?"
   - Options:
     - "Automated" — rules fully cover the requirement
     - "Partially automated" — rules cover some aspects
     - "Not applicable" — requirement doesn't apply to this product
     - "Skip for now" — don't change anything

## Phase 4: Write Selection

Based on author's decision:

### If rules were selected (automated or partially_automated):

1. Call `mcp__content-mcp__update_requirement_rules` with:
   - `control_id`: the control file ID
   - `requirement_id`: the requirement ID
   - `rules`: the selected rule IDs
   - `status`: "automated" or "partially_automated" based on author's choice
   - **Fallback**: Find the requirement file using `get_requirement_file_path` fallback (see above). Use `Edit` tool to update the `rules:` and `status:` fields in the YAML. Be careful to preserve existing formatting, comments, and Jinja2 templating.

2. Verify the result:
   - Check `success` field in the response
   - If failed, report the error and suggest manual editing

3. Report:
   ```
   Updated requirement '{requirement_id}' in '{control_id}':
   - Rules: {rules}
   - Status: {status}
   - File: {file_path}
   ```

### If marked not applicable:

1. Call `mcp__content-mcp__update_requirement_rules` with:
   - `control_id`: the control file ID
   - `requirement_id`: the requirement ID
   - `rules`: [] (empty list)
   - `status`: "not_applicable"
   - **Fallback**: Edit the requirement YAML directly to set `status: not_applicable` and `rules: []`.

2. Report the change.

### If skipped:

Report that no changes were made and move on.

## Phase 5: Summary

Present a brief summary:

```
## Mapping Complete

Requirement: {requirement_id} ({title})
Control file: {control_id}
Action: {mapped N rules / marked not applicable / skipped}
File modified: {file_path or "none"}

Next steps:
- Map another requirement: `/map-requirement {control_id} <next_req_id> --product {product}`
- Map all unmapped: `/map-controls {control_id} --product {product}`
- Review changes: `git diff controls/`
```

## Error Handling

- If `update_requirement_rules` fails, display the error message and suggest the user manually edit the file. Use `mcp__content-mcp__get_requirement_file_path` to find the correct file, or **Fallback**: locate it by reading the control YAML's `controls_dir:` field or searching for the requirement in the inline `controls:` list.
- If rule search returns no results, rely only on cross-framework candidates from step 2a.
- If no candidates are found from any source, inform the user and offer options: "Skip", "Enter rule IDs manually", "Create new rule (use /create-rule)".
