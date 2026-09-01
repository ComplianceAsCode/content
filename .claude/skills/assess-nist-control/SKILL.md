---
name: assess-nist-control
description: Assess a pending NIST 800-53 control with OSCAL enrichment, CIS reverse lookup, and Linux hardening prioritization. Guides authors through understanding, automatability analysis, rule mapping, and validation.
---

# Assess NIST Control

Assess pending NIST 800-53 Rev 5 controls for a product. This skill adds NIST-specific intelligence on top of the generic mapping workflow: full OSCAL control text (statement, guidance, assessment objectives), CIS-to-NIST reverse lookup for pre-existing rule associations, baseline awareness (low/moderate/high), and a prioritization strategy focused on Linux hardening.

Base controls are the primary work unit — each base control is assessed together with its enhancements as a single session.

**Arguments**: $ARGUMENTS — format: `[<control_id_or_family>] [--product <product_id>]`

Examples:
- `/assess-nist-control ac-7 --product rhel9` — assess base control AC-7 and its enhancements
- `/assess-nist-control ac --product rhel9` — triage the AC (Access Control) family
- `/assess-nist-control --product rhel9` — full prioritized triage across all families
- `/assess-nist-control cm-6 --product rhel10` — assess CM-6 for RHEL 10

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

**Without MCP server**: Cross-framework similarity search is unavailable. Candidate rules will be found by CIS reverse lookup, `nist:` reference grep, and keyword search only.

**NIST-specific data** is always read from the filesystem (no MCP equivalent):
- OSCAL catalog: `utils/nist_sync/data/nist_800_53_rev5_catalog.json`
- CIS-NIST mappings: `utils/nist_sync/data/cis_nist_mappings.json`
- Baselines: `utils/nist_sync/data/nist_800_53_rev5_{low,moderate,high}_baseline.json`
- Rule-variable mapping: handled by the `resolve-rule-variables` sub-skill, which reads `build/<product>/rule_variable_mapping.json` and `.var` files to collect variable value selections after rule selection in Phase 3.

## Phase 0: Parse and Resolve Target

1. **Parse arguments**: Extract optional `control_id_or_family` and `--product` from `$ARGUMENTS`.

2. **Detect mode**:
   - If argument matches `^[a-z]{2}$` (e.g., `ac`, `cm`) → **family triage mode** (Phase 1A)
   - If argument matches `^[a-z]{2}-\d+(\.\d+)?$` (e.g., `ac-7`, `ac-2.5`) → **single control mode** (Phase 1B). If an enhancement ID is given (has `.`), resolve to its base control (e.g., `ac-2.5` → assess `ac-2` including enhancement `ac-2.5`).
   - If no argument → **full triage mode** (Phase 1A across all families)

3. **Product validation**: Check that `products/<product>/controls/nist_800_53.yml` exists.
   - If `--product` not specified, ask via `AskUserQuestion`:
     - "Which product are you assessing NIST 800-53 controls for?"
     - Options: "rhel9", "rhel10", "rhel8", "Other"
   - If the NIST 800-53 control file does not exist for the product, inform the user and stop.

4. **Build check**: Call `mcp__content-agent__list_built_products`.
   - If the target product is NOT built, ask via `AskUserQuestion`:
     - "Product '{product}' has not been built yet. Rule search works best with build artifacts. Build now?"
     - Options:
       - "Yes, build now (Recommended)" — runs `/build-product {product} -d`
       - "No, continue without build" — rule search uses raw source files
   - If user chooses to build, invoke: `Skill(skill="build-product", args="{product} -d")`. Wait for completion.
   - **Fallback**: Check if `build/{product}/rules/` directory exists.

## Phase 1A: Prioritized Triage

When no specific control ID is given, present a prioritized view of pending work.

### Family prioritization order

Use this hardcoded priority order based on CIS mapping density and Linux hardening relevance:

| Priority | Family | Full Name | Rationale |
|----------|--------|-----------|-----------|
| 1 | cm | Configuration Management | 176 CIS-mapped rules, core hardening |
| 2 | ac | Access Control | 161 rules, access control fundamentals |
| 3 | au | Audit and Accountability | 106 rules, audit infrastructure |
| 4 | ia | Identification and Authentication | 26 rules, identity/auth |
| 5 | si | System and Information Integrity | Integrity checks, patching |
| 6 | sc | System and Communications Protection | Crypto, network protection |
| 7 | ca | Assessment, Authorization, Monitoring | Firewall, monitoring |
| 8+ | at, cp, ir, ma, mp, pe, pl, pm, ps, pt, ra, sa, sr | Organizational/procedural | Mostly non-automatable |

### Steps

1. **Read family files**: Read `products/<product>/controls/nist_800_53/<family>.yml` for each family in scope (single family or all 20).

2. **Count pending base controls**: For each family, count controls where `status == "pending"` and the ID does NOT contain a dot (base controls only). Enhancements are counted separately but shown as context — they will be assessed alongside their parent.

3. **Load CIS-NIST mappings**: Run:
   ```bash
   python3 -c "
   import json
   with open('utils/nist_sync/data/cis_nist_mappings.json') as f:
       data = json.load(f)
   from collections import Counter
   fam_rules = Counter()
   for rule_id, nist_ids in data['rules'].items():
       for nid in nist_ids:
           fam_rules[nid.split('-')[0]] += 1
   for var_sel, nist_ids in data['variables'].items():
       for nid in nist_ids:
           fam_rules[nid.split('-')[0]] += 1
   for fam in sorted(fam_rules, key=fam_rules.get, reverse=True):
       print(f'{fam} {fam_rules[fam]}')
   "
   ```
   **Fallback if cis_nist_mappings.json missing**: Skip CIS column, note it's unavailable.

4. **Present prioritized overview**:

   ```
   ## NIST 800-53 Assessment Triage ({product})

   ### High-Priority Families (Linux hardening)

   | # | Family | Name                        | Pending Base | CIS Rules | Automated |
   |---|--------|-----------------------------|-------------|-----------|-----------|
   | 1 | CM     | Configuration Management    | 10          | 176       | 4         |
   | 2 | AC     | Access Control              | 18          | 161       | 7         |
   | 3 | AU     | Audit and Accountability    | 9           | 106       | 7         |
   | 4 | IA     | Identification and Auth     | 8           | 26        | 5         |

   ### Medium Priority
   | 5 | SI     | System/Info Integrity        | 19          | 11        | 4         |
   | 6 | SC     | System/Comms Protection      | 45          | 8         | 6         |
   | 7 | CA     | Assessment/Monitoring        | 8           | 5         | 1         |

   ### Lower Priority (mostly organizational)
   | 8+ | AT, CP, IR, MA, MP, PE, PL, PM, PS, PT, RA, SA, SR — {N} pending base total |
   ```

5. **Ask which control to assess** via `AskUserQuestion`:
   - "Which control would you like to assess?"
   - Options: show 3 pending base controls from the highest-priority family that still has work, prioritized by most CIS-mapped rules for that specific control ID + "Pick a different family or control"
   - For each option, show: "cm-6: Configuration Change Control (CIS: 42 rules)" style description

6. Proceed to Phase 1B with the selected control.

## Phase 1B: Single Base Control — OSCAL Enrichment

Load and present the full NIST context for the selected base control AND all its enhancements.

### Step 1: Load control from control file

1. Derive family from control ID: `ac-7` → family `ac` → file `products/<product>/controls/nist_800_53/ac.yml`.
2. Read the family file and find the control entry matching the base ID.
3. Also collect all nested enhancements under the base control's `controls:` list.
4. Record current `status`, `rules`, and `levels` for the base and each enhancement.

### Step 2: Load OSCAL catalog data

Extract the control from the OSCAL catalog using a targeted Python command:

```bash
python3 -c "
import json, sys, re
cid = sys.argv[1]
family = cid.split('-')[0]
with open('utils/nist_sync/data/nist_800_53_rev5_catalog.json') as f:
    cat = json.load(f)['catalog']
for g in cat['groups']:
    if g['id'] == family:
        for c in g.get('controls', []):
            if c['id'] == cid:
                def render_parts(ctrl):
                    params = {p['id']: p.get('label', p['id']) for p in ctrl.get('params', [])}
                    result = {'id': ctrl['id'], 'title': ctrl['title'], 'params': ctrl.get('params', [])}
                    for part in ctrl.get('parts', []):
                        text = part.get('prose', '')
                        for pid, label in params.items():
                            text = text.replace('{{ insert: param, ' + pid + ' }}', '[' + label + ']')
                        result[part['name']] = text
                        subs = []
                        for sp in part.get('parts', []):
                            st = sp.get('prose', '')
                            for pid, label in params.items():
                                st = st.replace('{{ insert: param, ' + pid + ' }}', '[' + label + ']')
                            subs.append({'id': sp.get('id',''), 'name': sp.get('name',''), 'prose': st})
                        if subs:
                            result[part['name'] + '_parts'] = subs
                    result['enhancements'] = []
                    for ec in ctrl.get('controls', []):
                        result['enhancements'].append(render_parts(ec))
                    return result
                print(json.dumps(render_parts(c), indent=2))
                sys.exit(0)
print(json.dumps({'error': 'Control not found'}))
" "$BASE_CONTROL_ID"
```

If `utils/nist_sync/data/nist_800_53_rev5_catalog.json` does not exist:
> **Warning**: OSCAL catalog not found. Run `python3 utils/nist_sync/download_oscal.py` to download it. Proceeding with control file titles only.

### Step 3: Load baseline membership

```bash
python3 -c "
import json, sys
cid = sys.argv[1]
baselines = []
for level in ['low', 'moderate', 'high']:
    with open(f'utils/nist_sync/data/nist_800_53_rev5_{level}_baseline.json') as f:
        data = json.load(f)
    ids = set()
    for imp in data['profile']['imports']:
        for inc in imp.get('include-controls', []):
            ids.update(str(x) for x in inc.get('with-ids', []))
    if cid in ids:
        baselines.append(level.upper())
print(' '.join(baselines) if baselines else 'NONE')
" "$BASE_CONTROL_ID"
```

### Step 4: Present the enriched view

```
## NIST 800-53: {ID} — {Title}

**Baselines**: {LOW, MODERATE, HIGH}
**Current status**: {status}
**Current rules**: {rules or "none"}

### Statement
{Rendered OSCAL statement text with parameters replaced by [label]}
{Sub-parts as lettered clauses: a., b., c., ...}

### Guidance
{OSCAL guidance prose}

### Assessment Objectives
{Rendered assessment-objective parts as checklist items}

### Parameters
{List each parameter with its label and any guidelines}

### Enhancements ({N} total)
| ID      | Title                         | Baseline | Status  | Rules |
|---------|-------------------------------|----------|---------|-------|
| {id}.1  | {title}                       | {level}  | {status}| {n}   |
| {id}.2  | {title}                       | {level}  | {status}| {n}   |
```

If OSCAL data is unavailable, show only the control file title and skip Statement/Guidance/Assessment Objectives sections.

## Phase 2: Automatability Assessment

Gather intelligence from multiple sources to determine whether the control can be automated on a Linux system and which rules are candidates.

### Step 2a: CIS Reverse Lookup

Build a reverse index from `cis_nist_mappings.json` to find rules already associated with this NIST control:

```bash
python3 -c "
import json, sys
cid = sys.argv[1]
with open('utils/nist_sync/data/cis_nist_mappings.json') as f:
    data = json.load(f)
rules = sorted(r for r, nids in data['rules'].items() if cid in nids)
variables = sorted(v for v, nids in data['variables'].items() if cid in nids)
# Also check enhancements
import re
base = cid.split('.')[0]
enh_rules = {}
for r, nids in data['rules'].items():
    for nid in nids:
        if nid.startswith(base + '.'):
            enh_rules.setdefault(nid, []).append(r)
enh_vars = {}
for v, nids in data['variables'].items():
    for nid in nids:
        if nid.startswith(base + '.'):
            enh_vars.setdefault(nid, []).append(v)
print(json.dumps({'base_rules': rules, 'base_variables': variables,
                  'enhancement_rules': enh_rules, 'enhancement_variables': enh_vars}, indent=2))
" "$BASE_CONTROL_ID"
```

**Fallback if file missing**: Skip this step, note: "CIS-NIST mapping data not available."

### Step 2b: `nist:` Reference Grep

Search for rules that already reference this NIST control in their `rule.yml` `references: nist:` field.

Normalize the control ID for grep:
- Base control `ac-7` → grep for `AC-7` (uppercase)
- Enhancement `ac-2.5` → grep for `AC-2(5)` (dot becomes parenthetical)

```bash
# For the base control:
grep -rl "nist:.*AC-7" linux_os/guide/ applications/ 2>/dev/null | head -30

# Extract just rule IDs from the paths:
grep -rl "nist:.*AC-7" linux_os/guide/ applications/ 2>/dev/null | \
  xargs -I{} dirname {} | xargs -I{} basename {} | sort -u
```

Also search for each enhancement ID in parenthetical format.

### Step 2c: Cross-Framework Search

Follow the same cross-framework search as `map-requirement` Phase 2 Step 2a, substituting the OSCAL statement text (or control file title if OSCAL is unavailable) as the `requirement_text`. Use `exclude_control_id: nist_800_53`. This finds SRG, STIG, CIS, ANSSI, BSI requirements covering similar topics that already have rules mapped.

### Step 2d: Build Artifact Search

Follow the same build artifact search as `map-requirement` Phase 2 Step 2b, extracting key terms from the OSCAL statement text.

Deduplicate all results across all search steps (2a-2d).

### Step 2e: Automatability Analysis

Based on the OSCAL text, classify the control:

- **Automatable**: describes a technical configuration, system setting, audit rule, file permission, service state, cryptographic setting, or software behavior verifiable by scanning the OS. Look for words like: configure, enable, disable, set, enforce, implement, verify, ensure, limit.
- **Manual/organizational**: describes a policy, procedure, organizational process, physical security measure, personnel action, planning activity, or training requirement. Look for: develop, document, define, establish (policies), train, approve, review (periodic), coordinate, designate.
- **Mixed**: multi-clause controls where some clauses are automatable and others are organizational.

### Step 2f: Present Combined Assessment

```
### Automatability Assessment for {ID}: {Title}

**Classification**: {AUTOMATABLE / MANUAL / MIXED}
{Brief reasoning based on the OSCAL text analysis}

#### Candidate Rules ({N} total, deduplicated)

| Rule ID | Title | Sources |
|---------|-------|---------|
| {rule_id} | {title} | CIS, nist-ref |
| {rule_id} | {title} | cross-framework |
| {rule_id} | {title} | search |

#### Variable Selections from CIS
| Variable Selection | Mapped To |
|--------------------|-----------|
| {var=value}        | {control_id} |
```

If enhancements have their own candidates, show them separately:
```
#### Enhancement Candidates
| Enhancement | Rule ID | Title | Sources |
|-------------|---------|-------|---------|
| {enh_id}    | {rule}  | {title} | CIS |
```

Ask via `AskUserQuestion`:
- "How do you want to proceed with {ID}: {Title}?"
- Options:
  - "Map rules (Automated)" — description: "{N} candidate rules found"
  - "Mark as manual" — description: "Organizational/procedural control"
  - "Mark as not applicable" — description: "Does not apply to {product}"
  - "Skip for now" — description: "Leave as pending"

If "Mark as manual", "Mark as not applicable", or "Skip": update the control file accordingly (or skip) and jump to Phase 4.

## Phase 3: Rule Mapping (Base Control + Enhancements)

Assess the base control and all its enhancements as a single work unit.

### Step 3a: Map the Base Control

1–3. **Candidate discovery, validation, and selection**: Follow the same product availability check, rule detail retrieval, and candidate presentation as `map-requirement` Phase 2 Step 2c + Phase 3 Steps 1–2, using the NIST pre-loaded candidates from Step 2a (CIS) and Step 2b (nist: grep) as the primary candidate set — present these first, ranked above generic search results. The multiSelect question should read: "Select rules to map to {ID}: {Title}".

4. **Variable resolution**: After the user selects rules, resolve all variables those rules depend on.

   Invoke `Skill(skill="resolve-rule-variables", args="{product} {rule_id1} {rule_id2} ... [--cis-vars {var1=key1} ...]")`, passing the selected rule IDs and any CIS variable pre-selections from Step 2a. The skill guides the author through selecting a value key for each required variable and returns a list of `var_name=key` entries to include in the rules list alongside the rule IDs. If the skill reports no variable dependencies, skip to Step 5.

5. **Status selection** via `AskUserQuestion`:
   - "How should {ID} be marked?"
   - Options:
     - "automated" — rules fully cover the assessment objectives
     - "partial" — rules cover some but not all objectives
     - "manual" — organizational aspects remain
     - "Skip status change"

6. **Write to control file**: Call `mcp__content-agent__update_requirement_rules` with `control_id=nist_800_53`, `requirement_id`, selected rules (including variable selections), and status.
   - **Fallback**: Read `products/<product>/controls/nist_800_53/<family>.yml`, find the control entry by ID, update `rules:` and `status:` using the `Edit` tool. Preserve existing YAML formatting.

### Step 3b: Map Enhancements

For each enhancement of the base control:

1. **Show the enhancement context**: Display its OSCAL text (statement, guidance) and current status.

2. **Assess automatability**: Using the same classification as Phase 2 Step 2e, determine if the enhancement is automatable. Consider:
   - Some enhancements refine the base control and may use the same rules
   - Some enhancements address specific scenarios (e.g., mobile devices, biometrics) that may not apply to a Linux server
   - Some enhancements are purely organizational

3. **Present candidates**: Show rules specific to this enhancement (from CIS reverse lookup and cross-framework search) plus any base control rules that are also relevant.

4. **Ask the author** via `AskUserQuestion`:
   - "How should enhancement {enh_id}: {title} be handled?"
   - Options:
     - "Map rules" — if candidates exist, present multiSelect for rule selection
     - "Same rules as base control" — copy the base control's rules (including their variable selections)
     - "Manual" — organizational/procedural
     - "Not applicable" — doesn't apply (e.g., mobile device enhancement on a server)
     - "Skip for now"

5. **Variable resolution for enhancement rules**: If the author selected "Map rules" and chose specific rules, invoke `Skill(skill="resolve-rule-variables", args="{product} {rule_id1} ...")` for those rules. If "Same rules as base control", reuse the base control's rules list verbatim (variables already resolved).

6. **Write each enhancement**: Same write mechanism as Step 3a Step 6, but targeting the nested enhancement entry in the YAML.

### Step 3c: Write Summary

After all enhancements are processed, show what was written:

```
### Changes Written

| Control    | Status     | Rules Added |
|------------|------------|-------------|
| {base_id}  | automated  | 5 rules     |
| {enh_id}.1 | automated  | 3 rules     |
| {enh_id}.2 | not applicable | —      |
| {enh_id}.3 | manual     | —           |

File modified: products/{product}/controls/nist_800_53/{family}.yml
```

## Phase 4: Validate and Continue

### Step 1: Optional Build Validation

Ask via `AskUserQuestion`:
- "Build {product} to validate the control file changes?"
- Options:
  - "Yes, build now (Recommended)" — runs `Skill(skill="build-product", args="{product} -d")`
  - "No, skip validation"

If build fails, display the error. Common cause: YAML syntax error from the edit. Suggest: `git diff products/{product}/controls/nist_800_53/`

### Step 2: Updated Stats

Re-read the family file and present before/after:

```
### Updated Stats for {Family} Family

| Metric    | Before | After |
|-----------|--------|-------|
| Pending base controls  | {N} | {N-1} |
| Automated base controls | {N} | {N+1} |
| Pending enhancements    | {N} | {N-X} |
```

### Step 3: Suggest Next Control

From remaining pending base controls in the same family, suggest the next one. Prioritize by:
1. Controls with the most CIS-mapped rules (highest chance of finding existing rules)
2. Controls in higher-priority baselines (LOW before MODERATE before HIGH)

Ask via `AskUserQuestion`:
- "Assess another control?"
- Options:
  - "{next_id}: {title}" — description: "Baseline: {level} | CIS: {N} rules | {M} enhancements"
  - "Pick a different control or family"
  - "Done for now"

If user selects a control, loop back to Phase 1B.

### Step 4: Next Steps

```
### Next Steps
- Assess next control: `/assess-nist-control <next-id> --product {product}`
- Assess entire family: `/assess-nist-control {family} --product {product}`
- Map controls from other frameworks: `/map-controls <control_id> --product {product}`
- Review changes: `git diff products/{product}/controls/nist_800_53/`
- Build product: `/build-product {product}`
- Draft PR: `/draft-pr`
```

## Error Handling

- **OSCAL catalog missing** (`utils/nist_sync/data/nist_800_53_rev5_catalog.json`): Warn, proceed without OSCAL enrichment (use control file titles only). Suggest: `python3 utils/nist_sync/download_oscal.py`.
- **CIS mappings missing** (`utils/nist_sync/data/cis_nist_mappings.json`): Skip CIS reverse lookup. Rely on cross-framework search and `nist:` reference grep only.
- **Baseline files missing**: Skip baseline column in displays. Note: "Baseline data unavailable."
- **Control not found in family file**: List available base control IDs in the family, let user pick via `AskUserQuestion`.
- **Control not found in OSCAL catalog**: Proceed with control file title only. Note the discrepancy (may be a withdrawn control).
- **No candidate rules found from any source**: Present via `AskUserQuestion`:
  - "No automated rules found for this control."
  - Options: "Mark as manual", "Mark as not applicable", "Enter rule IDs manually", "Create new rule (use `/create-rule`)", "Skip for now"
- **YAML write failure**: Display error, show file path and the changes that need to be made manually.
- **Build failure after mapping**: Display build error, suggest reviewing `git diff`.
- **Variable resolution errors** (missing mapping file, missing `.var` file, rule not in mapping): Handled by the `resolve-rule-variables` skill. If the skill cannot proceed, it reports the issue and allows the author to continue without variable selections or add them manually.

## Important Notes

- **Base controls first**: Always resolve enhancement IDs to their base control and assess them together. An author asking about `ac-2.5` should be guided through `ac-2` and all its enhancements.
- **CIS mapping ID format**: The `cis_nist_mappings.json` uses lowercase IDs (`ac-7`, `ac-2.5`) matching control file IDs exactly.
- **`nist:` reference format**: Rule YAML uses uppercase with parenthetical enhancements: `AC-7`, `AC-2(5)`. Normalize when grepping.
- **The `update_requirement_rules` tool replaces existing rules** — if a control already has rules and the author wants to add more, include the existing rules in the selection.
- **Large families** (AC has 25 base controls, SC has 51): After the base control + enhancements session, always offer to continue with the next control rather than requiring the author to re-invoke the skill.
- **Don't overwhelm**: If candidate sources return many results, focus on the top 10-15 rules ranked by number of sources they appear in (CIS + nist-ref + cross-framework + search).
- **Variable selections**: `resolve-rule-variables` handles all variable logic — deduplication, key-vs-value distinction, default handling, and the "mandatory when a rule has variables" invariant. The caller (this skill) simply passes selected rule IDs to the sub-skill and includes the returned `var_name=key` entries alongside rule IDs in the `rules:` list write-back.
- **Planned: variables will move to a dedicated file**: Variable selections (`var_name=key` entries) are currently written inline alongside rule IDs in the NIST family control files. The long-term plan is to consolidate all variable selections into a separate per-product file so authors can review and tune values without touching rule mappings. Until that migration lands, continue writing variables inline.
