---
name: map-controls
description: Interactive control-to-rule mapping session. Walk through unmapped requirements, suggest rules using cross-framework analysis, and write selections to control files.
---

# Map Controls

Run an interactive mapping session for a control file. Walks through each unmapped requirement, finds candidate rules via cross-framework search and AI suggestions, lets the author select rules, and writes them back to the control file.

This skill orchestrates `/inspect-control` for setup and `/map-requirement` logic for each requirement.

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

**Without MCP server**: Cross-framework similarity search is unavailable. Candidate rules will be found by keyword search only, which may miss semantically similar but differently-worded requirements.

**Arguments**: $ARGUMENTS — format: `<control_id> [--product <product_id>] [--policy <path>]`

Examples:
- `/map-controls anssi --product rhel9`
- `/map-controls srg_gpos --product rhel10`
- `/map-controls hipaa`
- `/map-controls anssi --product rhel9 --policy security_policies/anssi_2.md`

## Phase 1: Setup and Validation

1. **Parse arguments**: Extract `control_id`, optional `--product`, and optional `--policy` from `$ARGUMENTS`.

2. **Load control stats**: Call `mcp__content-mcp__get_control_stats` with `control_id`.
   - If not found, call `mcp__content-mcp__list_controls` and present options via `AskUserQuestion`.
   - **Fallback**: Read `controls/<control_id>.yml` or `products/**/controls/<control_id>.yml`. Count requirements by status manually. List controls with `ls controls/*.yml` and `ls products/*/controls/*.yml`.

3. **If no `--product` specified**, ask user via `AskUserQuestion`:
   - "Which product are you mapping rules for?"
   - Options: "rhel9", "rhel10", "rhel8", "fedora" + Other

4. **Check build artifacts**: Call `mcp__content-mcp__list_built_products`.
   - If the target product is NOT in the built list, ask the user via `AskUserQuestion`:
     - "Product '{product}' has not been built yet. Rule search works best with build artifacts (expanded Jinja templates). Build it now?"
     - Options:
       - "Yes, build now (Recommended)" — description: "Runs `/build-product {product} --datastream-only` before starting the mapping session"
       - "No, continue without build" — description: "Rule search will use raw source files, which may miss some rules due to Jinja template parsing errors"
   - If user chooses to build, invoke the `build-product` skill: `Skill(skill="build-product", args="{product} --datastream-only")`. Wait for the build to complete before continuing.
   - **Fallback**: Check if `build/{product}/rules/` directory exists. If not, offer the build prompt above.

5. **Report summary**:
   ```
   ## Control File: {title} ({control_id})

   | Status    | Count |
   |-----------|-------|
   | Total     | {total} |
   | Mapped    | {mapped} |
   | Unmapped  | {unmapped} |
   ```
   Show the `by_status` breakdown, only including statuses with non-zero counts.

6. **If no `--policy` specified**, inform the user:
   > **Tip**: You can enrich mapping with the original security policy document by adding `--policy <path>` (supports PDF, Markdown, HTML). This provides full policy context for each requirement, improving cross-framework matching accuracy.

7. **Get work queue**: Call `mcp__content-mcp__list_unmapped_requirements` with `control_id`.
   **Fallback**: Read the control YAML and filter requirements where `status` is `pending` or `rules:` is empty/missing.

8. **Ask user scope** via `AskUserQuestion`:
   - "Which requirements do you want to work on?"
   - Options:
     - "Unmapped only ({N} requirements)" — work through the pending/unmapped queue
     - "All requirements ({total})" — review every requirement including already-mapped ones
     - "Specific requirement IDs" — let user type specific IDs

## Phase 2: Per-Requirement Mapping Loop

**Note**: Do NOT call `get_control_rule_index` here — it returns a massive payload (1.6MB+) that wastes context. The per-requirement `find_similar_requirements` call in Step 2b already provides cross-framework discovery for each requirement individually.

For each requirement in the selected work queue, execute the mapping workflow. This follows the same logic as `/map-requirement` but in batch.

### For each requirement:

#### Step 2a: Present the Requirement

Display:
```
---
### [{current}/{total}] Requirement: {requirement_id}
**Title**: {title}
**Description**: {description}
**Current status**: {status}
**Current rules**: {rules or "none"}
---
```

If `--policy` was provided:
1. **Infer document type** from the file extension (`.md` → `markdown`, `.pdf` → `pdf`, `.html` → `html`, otherwise → `text`)
2. Call `mcp__content-mcp__parse_policy_document` with `source`, `document_type`, and `requirement_id` for the current requirement.
   **Fallback**: For markdown/text, read the file and search for the requirement ID. For PDF, inform user that PDF parsing requires the MCP server.
3. If sections returned, display the policy context:
   ```
   ### Policy Context (from {policy_path})
   **{section_title}**
   {section_content}
   ```
4. Store the combined section text as `policy_text` for use in Step 2b

#### Step 2b: Cross-Framework Search

Call `mcp__content-mcp__find_similar_requirements` with:
- `requirement_text`: if `policy_text` is available, use it; otherwise use the requirement's title + " " + description
- `exclude_control_id`: current control_id
- `max_results`: 10

**Fallback**: Extract 3-5 key terms from the requirement text. Use `Grep` to search for each term across `controls/*.yml` and `products/*/controls/*.yml`. Read matched requirements to extract their `rules:` lists.

If results found, present grouped by framework:
```
Similar requirements in other frameworks:
- [{control_id}] {req_id}: "{title}" → rules: {rules}
```

Extract the union of all rules as cross-framework candidates.

#### Step 2c: Rule Search in Build Artifacts

Search for candidate rules using rendered build artifacts (Jinja-expanded, product-specific):

1. Extract 3-5 key terms from the requirement title and description.
2. For each key term, call `mcp__content-mcp__search_rendered_content` with:
   - `query`: the key term
   - `product`: the target product from Phase 1
   - `limit`: 15
   - **Fallback**: If the product is not built, use `Grep` to search for key terms in `rule.yml` files under `linux_os/guide/` and `applications/`. This may miss rules with Jinja-templated descriptions.

3. Deduplicate results across all term searches. Combine with cross-framework candidates from Step 2b.

4. For each candidate rule, use `mcp__content-mcp__get_rendered_rule` (or `get_rule_details`) to read its title and description. Reason about which rules best match the requirement semantically.

5. Present the top candidates in a table:
   ```
   ### Rule Candidates

   | Rule ID | Title | Source | Reasoning |
   |---------|-------|--------|-----------|
   | {rule_id} | {title} | cross-ref / search | {why it matches} |
   ```

#### Step 2d: Product Availability Check

Since `search_rendered_content` only returns rules present in the target product's build, all search results are already confirmed available. For cross-framework candidates (from Step 2b) that did NOT appear in the rendered search, call `mcp__content-mcp__get_rule_product_availability` to verify availability.
**Fallback**: Check each rule's `rule.yml` for `cce@<product>` entries and grep for the rule ID in target product profiles/controls.

Flag rules NOT available for the target product. Assess portability:
- Templated rules are likely portable
- Check platform constraints if present

#### Step 2e: Author Decision

1. Build unified candidate list: combine cross-framework and AI suggestions, deduplicated, sorted by confidence.

2. Use `AskUserQuestion` with `multiSelect: true`:
   - "Select rules for '{requirement_id}: {title}'"
   - Options: top candidates (up to 4), with confidence and source info
   - If more than 4 candidates, present top 3 + "Show more candidates"

3. Use a separate `AskUserQuestion`:
   - "How should this requirement be marked?"
   - Options:
     - "Automated" — fully covered
     - "Partially automated" — partially covered
     - "Not applicable" — doesn't apply
     - "Create new rule" — will be collected for gap analysis
     - "Skip for now"

#### Step 2f: Write Selection

- **If rules selected**: Call `mcp__content-mcp__update_requirement_rules` with `control_id`, `requirement_id`, `rules`, and appropriate `status`.
  **Fallback**: Find and edit the requirement's YAML file directly using `Edit` tool.
- **If not applicable**: Call `mcp__content-mcp__update_requirement_rules` with empty rules and `status="not_applicable"`.
  **Fallback**: Edit the requirement's YAML file to set `status: not_applicable` and `rules: []`.
- **If create new rule**: Add to the "new rules needed" list for Phase 3.
- **If skipped**: Record as skipped, move to next.

Track all changes for the final report.

## Phase 3: Gap Analysis

For requirements where the author chose "Create new rule":

1. For each gap requirement, use LLM analysis to:
   - Decompose the requirement into atomic checks (one config change per rule)
   - Suggest rule IDs following naming conventions (lowercase, underscores)
   - Suggest which template might apply (call `mcp__content-mcp__list_templates` and match; **Fallback**: `ls shared/templates/`)
   - Suggest severity based on the requirement

2. Present the decomposition:
   ```
   ### Gap: {requirement_id} — {title}

   This requirement could be covered by:
   1. {suggested_rule_id} (template: {template_name}) — {description}
   2. {suggested_rule_id} (template: {template_name}) — {description}
   ```

3. Ask user which rules to create via `AskUserQuestion`.

4. For each approved new rule, tell the user to run `/create-rule <rule_id>` with the suggested parameters after this session completes.

## Phase 4: Final Report

Present a complete summary of the mapping session:

```
## Mapping Session Complete

**Control file**: {control_id} ({title})
**Target product**: {product}

### Changes Made
- {X} requirements mapped to existing rules
- {Y} requirements marked not applicable
- {Z} requirements skipped

### Rules Added
| Requirement | Rules | Status |
|-------------|-------|--------|
| {req_id}    | {rules} | automated |
| ...         | ...   | ... |

### New Rules Needed
| Requirement | Suggested Rules | Template |
|-------------|----------------|----------|
| {req_id}    | {rule_ids}     | {template} |

### Updated Stats
```

Call `mcp__content-mcp__get_control_stats` again to show the updated coverage.
**Fallback**: Re-read the control YAML and recount requirements by status.
```
| Status   | Before | After |
|----------|--------|-------|
| Mapped   | {before} | {after} |
| Unmapped | {before} | {after} |
| Coverage | {before}% | {after}% |
```

```
### Next Steps
1. Review changes: `git diff controls/`
2. Build product: `/build-product {product}`
3. Create new rules: `/create-rule <rule_id>` for each gap
4. Test rules: `/test-rule <rule_id>`
5. Draft PR: `/draft-pr`
```

## Important Notes

- **The `update_requirement_rules` tool replaces existing rules** — if a requirement already has rules and the author wants to add more, include the existing rules in the selection.
- **AI suggestions require API key** — if `suggest_rule_mappings` fails, fall back to cross-framework search only.
- **Large control files** (e.g., srg_gpos with 300+ requirements) — consider processing in batches. After every 10 requirements, ask if the user wants to continue or pause.
- **Track before/after stats** — call `get_control_stats` at the start and end to show progress.
- **Don't overwhelm the user** — if cross-framework search and AI both return many candidates, focus on the top 5-10 with highest confidence.
