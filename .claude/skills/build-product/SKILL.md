---
name: build-product
description: Build a ComplianceAsCode product
---

# Build Product

Build a ComplianceAsCode product.

**Product**: $ARGUMENTS

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Validate Product

1. **Check if product is valid**:
   Use `mcp__content-mcp__get_product_details` with `product_id=$ARGUMENTS` to validate the product exists and get its metadata.
   **Fallback**: Read `products/$ARGUMENTS/product.yml` directly. If the file doesn't exist, the product is invalid.

2. **If product not found**, list available products:
   Use `mcp__content-mcp__list_products` to get all available products.
   **Fallback**: Run `ls products/` to list available product directories.

3. **If no product specified**, ask user using AskUserQuestion:
   - Use the product list to populate options
   - Allow "Other" for unlisted products

## Phase 2: Build Product

Build all artifacts (SCAP, guides, playbooks, tables):
```bash
./build_product $ARGUMENTS
```

### Build Output

Monitor build progress:
- CMake configuration
- Content resolution
- OVAL generation
- XCCDF generation
- Data stream assembly

Expected artifacts in `build/`:
- `ssg-$ARGUMENTS-ds.xml` - SCAP data stream
- `ssg-$ARGUMENTS-ds-1.2.xml` - SCAP 1.2 data stream
- `ssg-$ARGUMENTS-xccdf.xml` - XCCDF document
- `ssg-$ARGUMENTS-oval.xml` - OVAL definitions
- `guides/` - HTML guides
- `ansible/` - Ansible playbooks
- `bash/` - Bash scripts

## Phase 3: Verify Build Success

1. **Check build exit code**:
   - Exit 0 = Success
   - Non-zero = Build failed

2. **Verify key artifacts exist**:
   Use `mcp__content-mcp__get_datastream_info` with `product=$ARGUMENTS` to verify the datastream was built successfully and get artifact details.
   **Fallback**: Check files directly:
   ```bash
   ls -la build/ssg-$ARGUMENTS-ds.xml
   ls -la build/ssg-$ARGUMENTS-xccdf.xml
   ls -la build/ssg-$ARGUMENTS-oval.xml
   ```

3. **Check for build warnings**:
   - Look for deprecation warnings
   - Template processing warnings
   - Missing reference warnings

## Phase 4: Report Results

### Success Report

```
Build Complete
==============

Product: $ARGUMENTS

Build Status: SUCCESS
  Artifacts:
    - build/ssg-$ARGUMENTS-ds.xml
    - build/ssg-$ARGUMENTS-xccdf.xml
    - build/ssg-$ARGUMENTS-oval.xml

Ready for:
  - Validation tests: /run-tests
  - Automatus testing: /test-rule <rule_id>
  - OpenSCAP scanning: oscap xccdf eval --profile <profile> build/ssg-$ARGUMENTS-ds.xml
  - PR creation
```

### Build Failure Report

```
Build Failed
============

Product: $ARGUMENTS

Error Output:
[error message from build]

Common Causes:
  1. Jinja2 template syntax error in rule.yml
  2. Missing macro or variable reference
  3. Invalid platform specification
  4. Circular dependency in profiles

Debugging Steps:
  1. Check the specific file mentioned in the error
  2. Validate YAML: python3 -c "import yaml; yaml.safe_load(open('path/to/file.yml'))"
  3. Check Jinja2: Look for unclosed tags, missing macros
  4. Review recent changes: git diff HEAD~1
```

## Troubleshooting

### Common Build Errors

1. **CMake configuration failed**:
   ```bash
   # Ensure CMake is installed
   cmake --version

   # Try with explicit generator
   cd build && cmake -G "Unix Makefiles" ..
   ```

2. **Python import errors**:
   ```bash
   # Install requirements
   pip3 install -r requirements.txt
   pip3 install -r test-requirements.txt
   ```

3. **Missing dependencies**:
   ```bash
   # RHEL/Fedora
   dnf install cmake make openscap-utils python3-pyyaml python3-jinja2
   ```

4. **Jinja2 errors**:
   - Check for undefined macros
   - Verify macro imports in the file
   - Check for syntax errors in `{{{ }}}` blocks

5. **OVAL validation errors**:
   - Check template parameters match expected types
   - Verify referenced variables exist
   - Check platform applicability

### Verbose Build

For more detailed output:
```bash
./build_product $ARGUMENTS 2>&1 | tee build.log
```

### Ninja Build (Faster)

If ninja is available:
```bash
cd build
cmake -G Ninja ..
ninja $ARGUMENTS
```
