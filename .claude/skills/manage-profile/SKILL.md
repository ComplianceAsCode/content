---
disable-model-invocation: true
---

Create or update a versioned profile.

Arguments: $ARGUMENTS

Expected arguments: `<action> <profile_name> <product(s)> [version]`

Actions:
- `create` — Create a new versioned profile pair (versioned + unversioned)
- `update` — Bump an existing profile to a new version

For example:
- `create cis ocp4 1.7.0`
- `update cis ocp4 1.8.0`

## Background: Profile Versioning Pattern

This project uses a two-file versioning pattern for profiles (browse existing profiles under `products/<product>/profiles/` for examples):

- **Versioned profile** (e.g., `cis-v1-7-0.profile`): Contains the actual `selections`, `metadata.version`, and all profile configuration. Users pin to this for a stable baseline.
- **Unversioned profile** (e.g., `cis.profile`): Contains `extends: cis-v1-7-0` and no `selections` of its own. Users referencing this always get the latest version.

When multiple products are specified (e.g., `ocp4,rhcos4`), both profile pairs are created/updated under their respective `products/<product>/profiles/` directories.

---

## Action: `create`

### Step 1: Validate

1. Parse the product list (comma-separated). Valid product IDs are subdirectory names under `products/`.
2. Verify `products/<product>/profiles/` exists for each product.
3. Check that the profile does not already exist. If it does, suggest using `update` instead.
4. Convert the version to a filename-safe format by replacing dots with dashes (e.g., `2.0.0` → `v2-0-0`).

### Step 2: Check for a Control File

Check if a control file exists that matches the profile name. Control files live under `controls/` and `products/*/controls/`, typically named `<profile>_<product>.yml` or as a split directory with the same base name. If found:

1. Read the control file's top-level YAML to check the `product` field.
2. If the `product` field does not list all the products from the argument, warn the user and offer to update it. A control file needs all target products listed in its `product` field to work with each product's profile. Check existing multi-product control files for examples of this pattern.

### Step 3: Show the Proposed Files

For each product, show the two files that will be created:

**Versioned profile** (`products/<product>/profiles/<name>-<version>.profile`):
```yaml
---
documentation_complete: true

title: '<Title> for <Product Full Name>'

platform: <product>

metadata:
    version: <Version>

description: |-
    <Description text.>

selections:
    - <control_id>:all
```

**Unversioned profile** (`products/<product>/profiles/<name>.profile`):
```yaml
---
documentation_complete: true

title: '<Title> for <Product Full Name>'

platform: <product>

metadata:
    version: <Version>

description: |-
    <Description text.>

extends: <name>-<version>
```

Ask the user to confirm before creating.

### Step 4: Apply

Create all files for each product after approval.

---

## Action: `update`

### Step 1: Validate

1. Parse the product list.
2. Locate the existing unversioned profile for each product at `products/<product>/profiles/<name>.profile`.
3. Read the unversioned profile to find the current `extends` target (e.g., `cis-v1-7-0`).
4. Read the current versioned profile to get its `selections` and other configuration.
5. Convert the new version to filename-safe format (e.g., `2.1.0` → `v2-1-0`).

If the unversioned profile doesn't use `extends`, warn the user that it doesn't follow the versioning pattern and offer to convert it.

### Step 2: Show the Proposed Changes

For each product, show what will happen:

1. **New versioned profile** (`<name>-<new_version>.profile`): Created with the same `selections` as the current versioned profile (the user can modify selections afterward).
2. **Previous versioned profile** (`<name>-<old_version>.profile`): Add `status: deprecated` to mark it as superseded.
3. **Unversioned profile** (`<name>.profile`): Update `extends` to point to the new version and update `metadata.version`.

Ask the user to confirm before applying.

### Step 3: Apply

After approval:

1. Create the new versioned profile by copying the current versioned profile's content and updating `metadata.version`.
2. Add `status: deprecated` to the previous versioned profile.
3. Update the unversioned profile's `extends` field to reference the new versioned profile.
4. Update the unversioned profile's `metadata.version` to the new version.
5. Show the final state of all modified/created files.

---

## Notes

- **Product full names** for titles/descriptions: Read the `full_name` field from `products/<product>/product.yml` for each product.
- **Version format in filenames**: Replace dots with dashes and prefix with `v` (e.g., `2.0.0` → `v2-0-0`, `V2R3` → `v2r3`).
- **Version format in metadata**: Use the version as provided by the user (e.g., `V2.0.0`, `V2R3`).
- Always show the full proposed file contents before creating or modifying.
- When updating, preserve all existing `selections`, `filter_rules`, variables, and other configuration from the current versioned profile.
