---
name: onboard-control
description: Onboard a new security policy as a control file. Parse the document, create control file structure, and map existing rules to requirements.
---

# Onboard Control

Parse a security policy document (PDF, Markdown, HTML, or text), create a ComplianceAsCode control file structure from it, and optionally map existing rules to the extracted requirements.

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

**Without MCP server**: PDF parsing is unavailable (use markdown/text instead). Control file generation and validation must be done manually. Cross-framework similarity search for auto-mapping is unavailable; keyword-based search is used instead.

**Arguments**: $ARGUMENTS — format: `<document_path> [--id <policy_id>] [--product <product_id>] [--no-map]`

Examples:
- `/onboard-control security_policies/anssi_r2.pdf --id anssi --product rhel9`
- `/onboard-control security_policies/cis_benchmark_v1.md --id cis_workstation --product fedora`
- `/onboard-control https://example.com/policy.html --id my_policy --no-map`
- `/onboard-control security_policies/stig.pdf --id rhel9_stig --product rhel9`

## Phase 1: Parse and Validate Input

1. **Parse arguments**: Extract `document_path`, optional `--id <policy_id>`, optional `--product <product_id>`, and optional `--no-map` flag from `$ARGUMENTS`.

2. **Infer document type** from the file extension:
   - `.pdf` → `pdf`
   - `.md` → `markdown`
   - `.html` / `.htm` → `html`
   - Otherwise → `text`

3. **Validate product** (if specified): Call `mcp__content-agent__get_product_details` with `product_id`.
   - If not found, call `mcp__content-agent__list_products` and present options via `AskUserQuestion`:
     - "Product '{product_id}' not found. Which product is this control for?"
     - Options: top 4 relevant products + Other
   - **Fallback**: Check if `products/<product_id>/product.yml` exists. List products with `ls products/`.

4. **If no `--product` specified**, discover available products and ask the user via `AskUserQuestion`:
   - Run `ls products/` (or call `mcp__content-agent__list_products`) to get the list of available products
   - "Which product is this control file for? (optional — leave blank for product-agnostic)"
   - Options: present the most common products from the discovered list + "Product-agnostic (global controls/)" + Other

5. **Check for existing control**: If `--id` was provided, call `mcp__content-agent__get_control_stats` with `control_id` to check whether a control file with this ID already exists.
   **Fallback**: Check if `controls/<policy_id>.yml` or `products/<product>/controls/<policy_id>.yml` exists.
   - If it already exists, warn the user via `AskUserQuestion`:
     - "Control file '{policy_id}' already exists with {total} requirements. What would you like to do?"
     - Options:
       - "Overwrite" — proceed and replace
       - "Choose a different ID" — ask for new ID
       - "Abort"

## Phase 2: Parse the Policy Document

1. **Parse document**: Call `mcp__content-agent__parse_policy_document` with:
   - `source`: document_path
   - `document_type`: inferred type from Phase 1
   - **Fallback**: For markdown/text/HTML files, read the file directly and extract structure by splitting on headings. Identify requirements from numbered sections, bullet lists, or tables. For PDF files, inform the user that PDF parsing requires the MCP server and ask for a text/markdown alternative.

2. **Display parse results**:
   ```
   ## Parsed: {document_title}

   - Sections found: {count}
   - Requirements extracted: {count}
   - Document type: {type}
   ```

3. **Show extracted structure** — present a summary of sections and requirements:
   ```
   ### Document Structure

   | # | Section | Title | Requirements |
   |---|---------|-------|-------------|
   | 1 | 1.1     | Access Control | 5 |
   | 2 | 1.2     | Authentication | 3 |
   | ... | ... | ... | ... |
   ```

4. **If no requirements were extracted** (parsed document returned empty requirements):
   - Inform the user that automatic extraction found no structured requirements
   - Ask via `AskUserQuestion`:
     - "No requirements were automatically extracted. How would you like to proceed?"
     - Options:
       - "Show raw sections" — display all parsed sections so user can identify requirements
       - "Treat each section as a requirement" — use document sections directly as requirements
       - "Abort"
   - If "Show raw sections": display all section titles and first ~100 chars of content, then ask user to confirm which sections contain requirements
   - If "Treat each section as a requirement": map each section to a requirement with `id=section_id`, `title=section_title`, `description=section_content`

5. **Ask user to confirm** via `AskUserQuestion`:
   - "Proceed with {N} extracted requirements?"
   - Options:
     - "Yes, generate control files"
     - "Show all requirements first" — display full list before proceeding
     - "Abort"

## Phase 3: Determine Policy Metadata

1. **If `--id` not provided**, suggest a policy ID based on the document title:
   - Convert title to lowercase, replace spaces/special chars with underscores
   - Truncate to reasonable length
   - Ask user via `AskUserQuestion`:
     - "What ID should this control file use?"
     - Options:
       - "{suggested_id}" (based on document title)
       - "{alternative_id}" (shorter variant)
       - Other

2. **Ask for additional metadata** via `AskUserQuestion`:
   - Check existing control files for common level patterns: `grep -h 'id:' controls/*.yml products/*/controls/*.yml | grep -A5 'levels:' | head -20` or call `mcp__content-agent__list_controls` to see level schemes used in other frameworks
   - "Does this policy define compliance levels (e.g., high/medium/low, Level 1/Level 2)?"
   - Options: present common level schemes discovered from existing control files + "No levels" + Other

3. **Ask for version** if not obvious from the document:
   - "What version string should this control use? (e.g., 'v1r1', '1.0', leave blank to skip)"
   - Only ask if the document title or metadata doesn't already contain a clear version

## Phase 4: Generate Control File Structure

1. **Ask for output format** via `AskUserQuestion`:
   - "How should the control file be structured?"
   - Options:
     - "Directory (Recommended)" — parent YAML file + individual files per requirement in a subdirectory. Best for large policies with many requirements. Uses `controls_dir` in parent file.
     - "Inline" — single monolithic YAML file with all requirements in a `controls` list. Simpler for small policies with few requirements.

2. **Prepare requirements JSON**: Format the extracted requirements as JSON for the generation tool:
   ```json
   {
     "requirements": [
       {
         "id": "...",
         "title": "...",
         "description": "...",
         "section": "..."
       }
     ]
   }
   ```

3. **Generate control files**: Call `mcp__content-agent__generate_control_files` with:
   - `policy_id`: from Phase 3
   - `policy_title`: from parsed document title
   - `format`: `"directory"` or `"inline"` based on user choice
   - `requirements_json`: prepared JSON
   - `source_document`: original document path
   - `version`: if provided
   - `levels`: if provided
   - `product`: if specified (generates into `products/<product>/controls/` instead of `controls/`)
   - **Fallback**: Write the control YAML files manually using `Write` tool. Follow the `shared/schemas/control.json` schema for structure. For **inline** format, create a single YAML file with a `controls:` list. For **directory** format, create a parent YAML with `controls_dir:` and individual YAML files per requirement.

4. **Display generation result**:

   For **directory** format:
   ```
   ## Control Files Generated

   - Parent file: {parent_file_path}
   - Requirement files: {count} files in {directory}
   - Errors: {count}
   - Warnings: {count}
   ```

   For **inline** format:
   ```
   ## Control File Generated

   - File: {parent_file_path}
   - Requirements: {count} controls in file
   - Errors: {count}
   - Warnings: {count}
   ```

   If there are errors, display them and ask if the user wants to continue or abort.

4. **Validate generated files**: Call `mcp__content-agent__validate_control_file` with the generated parent file path.
   **Fallback**: Validate against the JSON schema:
   ```bash
   python3 -c "
   import json, yaml, sys
   from jsonschema import validate, ValidationError
   schema = json.load(open('shared/schemas/control.json'))
   data = yaml.safe_load(open(sys.argv[1]))
   try:
       validate(instance=data, schema=schema)
       print('Valid')
   except ValidationError as e:
       print(f'Invalid: {e.message}')
   " <path_to_control.yml>
   ```

5. **Display validation results**:
   ```
   ### Validation

   - Valid: {yes/no}
   - Errors: {list}
   - Warnings: {list}
   ```

   If validation fails, attempt to fix issues. Common fixes:
   - Missing required fields → add them
   - Invalid YAML syntax → regenerate the file
   - Rule references that don't exist → remove them (will be added during mapping)

## Phase 5: Initial Rule Mapping (unless `--no-map`)

If `--no-map` was NOT specified, offer to do an initial mapping pass.

1. **Ask user** via `AskUserQuestion`:
   - "Control file created with {N} requirements. Would you like to do an initial rule mapping now?"
   - Options:
     - "Yes, map all requirements" — full mapping session
     - "Yes, quick auto-map only" — automatic mapping without interactive review (cross-framework only)
     - "No, I'll map later with /map-controls"

2. **If "Yes, map all requirements"**: Hand off to the `/map-controls` workflow:
   - Tell the user: "Starting interactive mapping session. This follows the same workflow as `/map-controls {policy_id} --product {product} --policy {document_path}`."
   - Proceed with the map-controls Phase 2 logic (per-requirement mapping loop)

3. **If "Yes, quick auto-map only"**: Perform automatic mapping:

   For each requirement:
   a. Call `mcp__content-agent__find_similar_requirements` with:
      - `requirement_text`: requirement title + " " + description
      - `exclude_control_id`: current policy_id
      - `max_results`: 5
      - `min_similarity`: 0.4 (higher threshold for auto-mapping to avoid false positives)
      - **Fallback**: Extract key terms and grep across control files for matching requirements.

   b. Collect all rules from similar requirements across frameworks.

   c. If the target product is specified, call `mcp__content-agent__get_rule_product_availability` for the top candidate rules to verify they're available for the product.
      **Fallback**: Check each rule's `rule.yml` for `cce@<product>` identifiers.

   d. If confident matches found (rules appear in 2+ other frameworks for the same concept):
      - Call `mcp__content-agent__update_requirement_rules` with the matched rules and `status="automated"`.
        **Fallback**: Edit the requirement YAML directly using `Edit` tool.

   e. Track auto-mapped vs. skipped requirements.

   After the auto-map pass, report results:
   ```
   ### Auto-Mapping Results

   - Auto-mapped: {X} requirements
   - Skipped (no confident match): {Y} requirements
   - Total rules assigned: {Z}

   | Requirement | Rules | Source Frameworks |
   |-------------|-------|-------------------|
   | {req_id}    | {rules} | {frameworks} |
   ```

4. **If "No"**: Skip mapping, proceed to Phase 6.

## Phase 6: Final Report

Present a summary of the onboarding:

```
## Control Onboarding Complete

**Policy**: {policy_title}
**Control ID**: {policy_id}
**Product**: {product or "global"}
**Source**: {document_path}

### Files Created
- Control file: {parent_file_path}
- Format: {inline or directory}
- Requirements: {count} (inline: in single file / directory: individual files in {directory})

### Mapping Status
```

Call `mcp__content-agent__get_control_stats` with the new `control_id` (and `product` if specified) to show current state.
**Fallback**: Read the generated control YAML and count requirements by status.

```
| Status    | Count |
|-----------|-------|
| Total     | {total} |
| Mapped    | {mapped} |
| Unmapped  | {unmapped} |
| Coverage  | {percentage}% |
```

```
### Next Steps

1. Review generated files: `git diff controls/` or `git status`
2. Inspect the control: `/inspect-control {policy_id}`
3. Map remaining requirements: `/map-controls {policy_id} --product {product} --policy {document_path}`
4. Map a single requirement: `/map-requirement {policy_id} <req_id> --product {product}`
5. Build product: `/build-product {product}`
6. Draft PR: `/draft-pr`
```

## Important Notes

- **Exact text preservation**: The parsed document text is stored verbatim in requirement descriptions. No AI rewording happens during parsing.
- **Two output formats**: The `format` parameter controls the structure:
  - `"directory"` (recommended for most policies): Creates a parent YAML file with a `controls_dir` reference and individual YAML files per requirement in a subdirectory. The subdirectory is flat (not nested by section).
  - `"inline"`: Creates a single monolithic YAML file with all requirements in a `controls` list. Suitable for small policies.
- **Product-specific controls**: When `--product` is specified, files are generated in `products/<product>/controls/` which takes precedence over global `controls/` for that product.
- **Large documents**: For documents with 100+ requirements, the auto-map option in Phase 5 is recommended over interactive mapping, as the full interactive session can be very long. Use `/map-controls` afterward for requirements that need manual attention.
- **Duplicate detection**: Phase 1 checks for existing control files to prevent accidental overwrites.
- **Do NOT call `get_control_rule_index`** — it returns a 1.6MB+ payload. Use per-requirement `find_similar_requirements` instead.
- **Version detection**: Try to detect version from the document title or metadata before asking the user (e.g., "STIG V3R4" → `v3r4`, "CIS Benchmark v1.0" → `v1.0`).
