# MCP Fallback Reference

When the `mcp__content-mcp__*` tools are not available, use these filesystem-based alternatives.

## Simple Lookups

### list_products
```bash
ls products/
```
For details, read `products/<product_id>/product.yml`.

### get_product_details
Read `products/<product_id>/product.yml` directly.

### list_templates
```bash
ls shared/templates/
```

### get_template_schema
Read the template files in `shared/templates/<template_name>/`. Look for `template.yml` or `template.py` for parameter definitions. Also check `shared/templates/<template_name>/tests/` for usage examples.

### list_profiles
```bash
ls products/<product>/profiles/*.profile
```

### get_profile_details
Read `products/<product>/profiles/<profile_id>.profile` directly.

### list_controls
```bash
ls controls/*.yml
ls products/*/controls/*.yml
```

### get_control_details
Read the control YAML file directly:
- Global: `controls/<control_id>.yml`
- Product-specific: `products/<product>/controls/<control_id>.yml`

If the file has `controls_dir:`, individual requirement files are in the referenced subdirectory.

### get_control_stats
Read the control YAML and count requirements by status. Parse the `controls:` list (inline format) or read all files in `controls_dir:` (directory format). Count entries grouped by `status` field.

### list_unmapped_requirements
Read the control YAML and filter requirements where `status` is `pending` or where `rules:` is empty/missing.

### get_requirement_file_path
- **Inline format**: The requirement is in the main control YAML file (e.g., `controls/<control_id>.yml`)
- **Directory format**: Check the `controls_dir:` field in the parent YAML, then look for `<requirement_id>.yml` in that directory.

### list_built_products
```bash
ls build/ssg-*-ds.xml 2>/dev/null | sed 's|build/ssg-||;s|-ds.xml||'
```

### get_datastream_info
```bash
ls -la build/ssg-<product>-ds.xml
```

### search_rules
Use Glob to find rule.yml files and Grep to match keywords:
```
Glob: **/rule.yml
Grep: "<keyword>" in matched files
```

### get_rule_details
Find and read the rule.yml:
```
Glob: **/<<rule_id>>/rule.yml
```
Then read the file. The rule directory is typically under `linux_os/guide/` or `applications/`.

### search_control_requirements
Grep through control files for the query text:
```
Grep: "<query>" in controls/*.yml and products/*/controls/*.yml
```

### get_rule_product_availability
Search for the rule ID across product profiles and control files:
```
Grep: "<rule_id>" in products/*/profiles/*.profile
Grep: "<rule_id>" in products/*/controls/*.yml
Grep: "<rule_id>" in controls/*.yml
```
Also check the rule's `identifiers:` section in `rule.yml` for `cce@<product>` entries.

### get_rendered_rule
Read from build artifacts:
```bash
cat build/<product>/rules/<rule_id>.yml
```

### search_rendered_content
Grep through build artifacts:
```
Grep: "<query>" in build/<product>/rules/
```

## Complex Operations

### find_similar_requirements

No direct filesystem equivalent for semantic similarity. Fallback approach:

1. Extract 3-5 key terms from the requirement text (nouns, technical terms).
2. Grep each term across all control files:
   ```
   Grep: "<term>" in controls/*.yml and products/*/controls/*.yml
   ```
3. Requirements that match multiple terms are likely similar.
4. Read matched requirements and extract their `rules:` lists.
5. The union of rules from matched requirements forms the cross-framework candidates.

This is less precise than the MCP tool's text similarity but catches most obvious matches.

### parse_policy_document

- **Markdown/text files**: Read the file directly. Split by headings (`#`, `##`, etc.) to identify sections. Extract requirement IDs from section headers or numbered lists.
- **HTML files**: Read the file. The markup is usually readable enough to extract structure.
- **PDF files**: Cannot be parsed without the MCP server. Inform the user:
  > PDF parsing requires the content-mcp server. Please convert the PDF to markdown or text first, or configure the MCP server.

### update_requirement_rules

Edit the control YAML directly using the `Edit` tool.

**Inline format** (requirements in main YAML under `controls:` list):
1. Read the control file.
2. Find the requirement by `id:`.
3. Replace or add the `rules:` list and `status:` field.
4. Use `Edit` tool to make the change.

**Directory format** (individual files in `controls_dir:`):
1. Find the requirement file (see `get_requirement_file_path` above).
2. Edit the `rules:` and `status:` fields.

**Warning**: Be careful to preserve existing YAML formatting, comments, and Jinja2 templating (`{{% ... %}}`).

### generate_rule_boilerplate / generate_rule_from_template

Create the rule directory and files manually using `Write` tool:

```
<location>/<rule_id>/
├── rule.yml
```

For non-templated rules, also create skeleton files:
```
├── oval/shared.xml
├── bash/shared.sh
├── ansible/shared.yml
└── tests/
    ├── correct.pass.sh
    └── wrong.fail.sh
```

The skill instructions contain the skeleton file templates to use.

### generate_control_files

Write the control YAML structure manually using `Write` tool.

**Inline format**: Single YAML file with all requirements in a `controls:` list.
**Directory format**: Parent YAML file with `controls_dir:` reference + individual YAML files per requirement.

See `shared/schemas/control.json` for the expected structure.

## Validation

### validate_rule_yaml

Validate against the JSON schema:
```bash
python3 -c "
import json, yaml, sys
from jsonschema import validate, ValidationError
schema = json.load(open('shared/schemas/rule.json'))
data = yaml.safe_load(open(sys.argv[1]))
try:
    validate(instance=data, schema=schema)
    print('Valid')
except ValidationError as e:
    print(f'Invalid: {e.message}')
" <path_to_rule.yml>
```

If `jsonschema` is not installed, do a manual check of required fields: `documentation_complete`, `title`, `description`, `rationale`, `severity` (must be one of: high, medium, low, unknown).

### validate_control_file

Validate against the JSON schema:
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

If `jsonschema` is not installed, do a manual check:
- Each control in `controls:` list must have a `title` field
- `status` must be one of: automated, documentation, does not meet, inherently met, manual, not applicable, partial, pending, planned, supported
- `rules` and `levels` must be arrays of strings if present
