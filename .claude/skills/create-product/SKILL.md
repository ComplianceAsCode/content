---
name: create-product
description: Create a new product in ComplianceAsCode project
argument-hint: "<product_id> <product_full_name>"
---

# Create Product

Create all necessary files and directories so that a new product can be built in this project. A "product" represents an operating system (e.g., RHEL 11, Ubuntu 26.04) or an application (e.g., Firefox, Nginx).

The skill produces a minimal but buildable product skeleton. The product must build successfully with `build_product` by the end.

**Arguments**: $ARGUMENTS — optional, format: `<product_id> <product_full_name>`

For additional background on creating products, read `docs/manual/developer/03_creating_content.md`.

**Out of scope**: creating controls, creating profiles beyond a minimal default, porting content from other products, developing new rules, adjusting existing rules for the new product, updating Automatus tests, adding reference files or overlays.

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Gather product information

If `$ARGUMENTS` provides a product ID and full name, use them. Otherwise, ask the user using AskUserQuestion for:

1. **Full product name** (e.g., "Red Hat Enterprise Linux 11", "Ubuntu 24.04").
2. **Product ID** — must be lowercase, no spaces, consistent with existing product IDs (e.g., `rhel11` follows `rhel10`). Suggest an ID based on the full name and existing patterns.
3. **Product type** — ask whether this is a Linux OS or an application.

Then determine whether this is a **new major version** of an existing product (e.g., creating `rhel11` when `rhel10` exists) or an **entirely new product family** (no similar product in the project). Use `mcp__content-agent__list_products` to check existing products.
**Fallback**: Run `ls products/` to list existing product directories.

**Verify the product ID is not already taken**:
1. Check that no `products/<product_id>/` directory exists.
2. Check that the product ID does not appear in the `product_directories` list in `ssg/constants.py`.

## Phase 2: Create the product directory

1. Create the directory `products/<product_id>/`.
2. Create `products/<product_id>/CMakeLists.txt`. Find the most similar existing product's `CMakeLists.txt` and adapt it. The minimal content is:
```cmake
# Sometimes our users will try to do: "cd <product_id>; cmake ." That needs to error in a nice way.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

ssg_build_product("<product_id>")
```
Some products also include `set(PRODUCT_REMEDIATION_LANGUAGES "<product_id>")` before the `ssg_build_product` call. Check the most similar product's `CMakeLists.txt` and match its structure.

3. Create subdirectories `products/<product_id>/controls/` and `products/<product_id>/profiles/`. These will be empty for now but are needed by the build system.

## Phase 3: Create Benchmark

- **If the product is a Linux OS**: no action needed. Linux products reuse `linux_os/guide/` as their benchmark directory (configured via `benchmark_root` in `product.yml` in Phase 5).
- **If the product is an application**: create `products/<product_id>/guide/` and add a `benchmark.yml` file inside it. Read an existing application product's `benchmark.yml` (e.g., from `applications/`) for the expected format and adapt it for the new product.

## Phase 4: Update the build system

All insertions in this phase should maintain **alphabetical order** within each section.

### 4.1: Update `build_product` script

Add the new product (in UPPERCASE) to the `all_cmake_products` array in alphabetical order.

Example — to add `rhel11`:
```bash
all_cmake_products=(
    ...
    RHEL10
    RHEL11    # <-- insert here
    RHV4
    ...
)
```

### 4.2: Update root `CMakeLists.txt`

The root `CMakeLists.txt` has three separate sections that all need updating. The product ID must be **UPPERCASE** in CMake variables (e.g., `SSG_PRODUCT_RHEL11`).

**Section 1: CMake option**. Add:
```cmake
option(SSG_PRODUCT_<PRODUCT_ID_UPPER> "If enabled, the <Full Name> SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
```

**Section 2: Status message**. Add:
```cmake
message(STATUS "<Display Name>: ${SSG_PRODUCT_<PRODUCT_ID_UPPER>}")
```

**Section 3: Subdirectory** (around line 384-490). Add:
```cmake
if(SSG_PRODUCT_<PRODUCT_ID_UPPER>)
    add_subdirectory("products/<product_id>" "<product_id>")
endif()
```

Example for `rhel11`:
```cmake
# Section 1:
option(SSG_PRODUCT_RHEL11 "If enabled, the RHEL11 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})

# Section 2:
message(STATUS "RHEL 11: ${SSG_PRODUCT_RHEL11}")

# Section 3:
if(SSG_PRODUCT_RHEL11)
    add_subdirectory("products/rhel11" "rhel11")
endif()
```

### 4.3: Update `ssg/constants.py`

Update the following data structures:

**`product_directories` list**: Add the product ID string in alphabetical order.

**`FULL_NAME_TO_PRODUCT_MAPPING` dict**: Add a mapping from the full product name to the product ID.
```python
"Red Hat Enterprise Linux 11": "rhel11",
```

**`MULTI_PLATFORM_LIST` and `MULTI_PLATFORM_MAPPING` dict**:
- If the product is a **new major version** of an existing family (e.g., `rhel11` when `rhel` already exists): add the product ID to the existing list in `MULTI_PLATFORM_MAPPING`. Do NOT add a new entry to `MULTI_PLATFORM_LIST`.
  ```python
  "multi_platform_rhel": ["rhel8", "rhel9", "rhel10", "rhel11"],
  ```
- If the product is an **entirely new family**: add the family name to `MULTI_PLATFORM_LIST` and add a new entry to `MULTI_PLATFORM_MAPPING`.
  ```python
  MULTI_PLATFORM_LIST = [..., "newproduct"]
  MULTI_PLATFORM_MAPPING = {
      ...
      "multi_platform_newfamily": ["newproduct"],
  }
  ```

**`MAKEFILE_ID_TO_PRODUCT_MAP` dict**: This dict maps **family prefixes** (not full product IDs) to display names. For a new version of an existing family, the existing entry already covers it — no change needed. Only add a new entry for an entirely new product family.

### 4.4: Validate Python changes

After editing `ssg/constants.py`, verify it still imports cleanly:
```bash
python3 -c "from ssg import constants; print('OK')"
```

## Phase 5: Create product.yml

Create `products/<product_id>/product.yml`. Find the most similar existing product's `product.yml` (use `mcp__content-agent__get_product_details` or read directly from `products/`) and adapt it for the new product.
**Fallback**: Read `products/<similar_product>/product.yml` directly.

Copy all fields from the similar product and update values for the new product. Key fields to set correctly:
- `product`: the product ID
- `full_name`: the full product name
- `type`: typically `platform` for OS products
- `benchmark_root`: `"../../linux_os/guide"` for Linux OS products, `"./guide"` for application products
- `components_root`: only for Linux operating system products, typically `"../../components"`
- `pkg_manager`: package manager (e.g., `"dnf"`, `"apt_get"`, `"zypper"`), only for  for Linux OS products
- `init_system`: init system (e.g., `"systemd"`), only for Linux OS products
- `cpes`: must reference a `check_id` that matches the OVAL file created in Phase 6

### Example: product.yml for a RHEL-based product

```yaml
product: rhel9
full_name: Red Hat Enterprise Linux 9
type: platform

families:
  - rhel
  - rhel-like

major_version_ordinal: 9

benchmark_id: RHEL-9
benchmark_root: "../../linux_os/guide"
components_root: "../../components"

profiles_root: "./profiles"

pkg_manager: "dnf"

init_system: "systemd"

cpes_root: "../../shared/applicability"
cpes:
  - rhel9:
      name: "cpe:/o:redhat:enterprise_linux:9"
      title: "Red Hat Enterprise Linux 9"
      check_id: installed_OS_is_rhel9
```

## Phase 6: Create CPE OVAL check

Create `shared/checks/oval/<check_id>.xml` where `<check_id>` matches the `check_id` value set in `product.yml` (Phase 5).

**How to create it**: find the CPE OVAL file for the most similar existing product in `shared/checks/oval/` and adapt it. If this is a new major version, the new OVAL must be consistent with the existing version's OVAL (same structure, updated version numbers).

**Requirements**:
- The file must use the shorthand format (wrapped in `<def-group>`), not a full standalone OVAL file.
- The OVAL definition must evaluate to `true` when running on the new product.

Example for a `hummingbird` product:


```
<def-group>
  <definition class="inventory" id="installed_OS_is_hummingbird" version="3">
    <metadata>
      <title>Installed operating system is hummingbird</title>
      <affected family="unix">
        <platform>multi_platform_all</platform>
      </affected>
      <reference ref_id="cpe:/a:redhat:hummingbird" source="CPE" />
      <description>The operating system installed on the system is hummingbird</description>
    </metadata>
    <criteria operator="AND">
      <extend_definition comment="Installed OS is part of the Unix family" definition_ref="installed_OS_is_part_of_Unix_family" />
      <criterion comment="hummingbird-release RPM packages are installed" test_ref="test_hummingbird_release_rpm" />
      <criterion comment="CPE vendor is 'redhat' and product is 'hummingbird'" test_ref="test_hummingbird_vendor_product" />
    </criteria>
  </definition>

  <linux:rpminfo_test check="all" check_existence="at_least_one_exists" comment="hummingbird-release RPM packages are installed" id="test_hummingbird_release_rpm" version="1">
    <linux:object object_ref="object_hummingbird_release_rpm" />
  </linux:rpminfo_test>
  <linux:rpminfo_object id="object_hummingbird_release_rpm" version="1">
    <linux:name operation="pattern match">hummingbird-release.*</linux:name>
  </linux:rpminfo_object>

  <ind:textfilecontent54_test check="all" comment="CPE vendor is 'redhat' and 'product' is hummingbird" id="test_hummingbird_vendor_product" version="1">
    <ind:object object_ref="object_hummingbird_vendor_product" />
  </ind:textfilecontent54_test>
  <ind:textfilecontent54_object id="object_hummingbird_vendor_product" version="1">
    <ind:filepath>/etc/system-release-cpe</ind:filepath>
    <ind:pattern operation="pattern match">^cpe:\/a:redhat:hummingbird:[\d]+$</ind:pattern>
    <ind:instance datatype="int" operation="equals">1</ind:instance>
  </ind:textfilecontent54_object>

</def-group>
```

This example shows a typical CPE OVAL for a Linux OS product. Key points:
- `definition@id` must match the `check_id` from `product.yml`
- `reference@ref_id` must match the `name` (CPE URI) from `product.yml`
- The definition checks three things: (1) the OS is Unix-family, (2) a product-specific RPM is installed, (3) `/etc/system-release-cpe` contains the expected CPE string

For application products, the CPE OVAL typically just checks that the application's RPM package is installed.

## Phase 7: Create a minimal profile

The product must have at least one profile containing at least one rule, otherwise the build will fail.

1. Ask the user (using AskUserQuestion) if they want to adopt a profile from a similar existing product. If yes, copy it from the similar product's `profiles/` directory and adapt it.
2. If the user has no preference, create a minimal standard profile in `products/<product_id>/profiles/standard.profile` that selects a single broadly-applicable rule, eg. `installed_OS_is_vendor_supported`.

### Minimal standard profile example

```yaml
documentation_complete: true

title: 'Standard Profile for <Full Product Name>'

description: |-
    A standard compliance profile for <Full Product Name>.

selections:
    - installed_OS_is_vendor_supported
```

## Phase 8: Build and verify

1. Build the product:
   ```bash
   ./build_product --datastream-only <product_id>
   ```
2. Verify the build succeeded and that `build/ssg-<product_id>-ds.xml` exists.
3. If the build fails, read the error output, fix the issue, and rebuild. Common causes of build failures for new products:
   - Missing or empty profile (no rules selected) — fix in Phase 7
   - `product.yml` referencing a CPE `check_id` that doesn't match the OVAL file name from Phase 6
   - Product ID not added to all required places in `ssg/constants.py` (Phase 4)
   - The root `CMakeLists.txt` may try to build optional artifacts that don't exist yet for the new product — if the error is about a missing optional feature (e.g., STIG tables, overlay files), the fix is typically to guard the relevant CMake block with a condition or to skip non-essential build targets

## Phase 9: Report

List all created and modified files, grouped by phase. Suggest next steps:
- Create controls and profiles: `/map-controls`, `/create-rule`
- Full build: `/build-product <product_id>`
