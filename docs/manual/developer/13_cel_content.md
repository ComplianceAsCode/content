# CEL Content

## Introduction

CEL (Common Expression Language) is an alternative scanning mechanism to OVAL that provides native Kubernetes resource evaluation. CEL rules are used by the [compliance-operator](https://github.com/ComplianceAsCode/compliance-operator) to perform compliance checks on Kubernetes and OpenShift resources without requiring shell access or OVAL evaluation.

This document describes how to create CEL rules and profiles, and how the build system generates CEL content.

## When to Use CEL Rules

Use CEL rules when:
- Checking Kubernetes or OpenShift API resources (Pods, Deployments, ConfigMaps, etc.)
- Evaluating Custom Resource Definitions (CRDs)
- Performing compliance checks that don't require shell access to nodes
- Building platform-level compliance checks for container orchestration systems

Continue using OVAL/template-based rules for:
- File system checks
- Process checks
- Package installation verification
- Traditional operating system compliance checks

## CEL Rule Format

CEL rules are defined using the same `rule.yml` format as other rules, with additional CEL-specific fields.

### Required Fields for CEL Rules

```yaml
documentation_complete: true

title: 'Short descriptive title'

description: |-
    Full description of what the rule checks.

rationale: |-
    Why this rule matters for security/compliance.

severity: medium  # low, medium, high

scanner_type: CEL  # REQUIRED: Marks this as a CEL rule

check_type: Platform  # Type of check (usually Platform for K8s checks)

expression: |-
    # REQUIRED: CEL expression that evaluates to boolean
    resource.spec.enabled == true

inputs:  # REQUIRED: List of Kubernetes resources to evaluate
  - name: resource
    kubernetes_input_spec:
      api_version: v1
      resource: pods
      resource_name: my-pod  # Optional: specific resource name
      resource_namespace: default  # Optional: specific namespace
```

### Optional Fields

```yaml
ocil: |-
    Manual verification instructions.
    This becomes the "instructions" field in CEL content output.

failure_reason: |-
    Custom message displayed when the check fails.

references:
    cis@ocp4: 1.2.3
    nist: CM-6,CM-6(1)
    srg: SRG-APP-000516-CTR-001325
```

### CEL Expression

The `expression` field contains a CEL expression that evaluates to a boolean value:
- `true` means the check passes (compliant)
- `false` means the check fails (non-compliant)

CEL expressions can reference inputs by name and use standard CEL operators and functions.

#### Example Expressions

Simple boolean check:
```yaml
expression: resource.spec.enabled == true
```

Checking for absence:
```yaml
expression: !has(hco.spec.storageImport) || hco.spec.storageImport.insecureRegistries.size() == 0
```

Multiple conditions:
```yaml
expression: |-
    resource.spec.replicas >= 3 &&
    has(resource.spec.template.spec.securityContext) &&
    resource.spec.template.spec.securityContext.runAsNonRoot == true
```

### Input Specifications

The `inputs` field lists Kubernetes resources that the CEL expression can reference.

#### Kubernetes Input Spec

```yaml
inputs:
  - name: deployment  # Name used in the expression
    kubernetes_input_spec:
      api_version: apps/v1  # Kubernetes API version
      resource: deployments  # Resource type (plural form)
      resource_name: my-app  # Optional: specific resource name
      resource_namespace: kube-system  # Optional: specific namespace
```

If `resourceName` is omitted, the check applies to all resources of that type.
If `resourceNamespace` is omitted, the check applies across all namespaces.

## CEL Profile Format

CEL profiles use the standard profile format with one additional field:

```yaml
documentation_complete: true

title: 'CIS Red Hat OpenShift Virtual Machine Extension Benchmark'

description: |-
    Profile description text.

scanner_type: CEL  # REQUIRED: Marks this as a CEL profile

selections:
    - kubevirt-nonroot-feature-gate-is-enabled
    - kubevirt-no-permitted-host-devices
    - kubevirt-persistent-reservation-disabled
```

**Important:** CEL profiles can only select CEL rules. If a profile includes both CEL and OVAL rules, only the CEL rules will be included in the generated CEL content file.

## Creating a CEL Rule

### 1. Choose the Correct Directory

CEL rules for Kubernetes/OpenShift should go under `applications/openshift/` or `applications/openshift-virtualization/`, organized by component:

```
applications/openshift-virtualization/
├── group.yml
├── kubevirt-nonroot-feature-gate-is-enabled/
│   └── rule.yml
├── kubevirt-no-permitted-host-devices/
│   └── rule.yml
└── kubevirt-enforce-trusted-tls-registries/
    └── rule.yml
```

**Important:** Directory names should use hyphens (e.g., `kubevirt-nonroot-enabled`), not underscores. This follows Kubernetes naming conventions.

### 2. Create the group.yml

Each component directory requires a `group.yml` file:

```yaml
documentation_complete: true

title: 'OpenShift Virtualization'

description: |-
    Security recommendations for OpenShift Virtualization (KubeVirt).
```

### 3. Create the rule.yml

Follow the CEL rule format described above. Example:

```yaml
documentation_complete: true

title: 'Ensure NonRoot Feature Gate is Enabled'

description: |-
    The NonRoot feature gate restricts containers from running as root,
    reducing the attack surface.

rationale: |-
    Running containers as non-root users is a security best practice
    that limits the impact of container breakout vulnerabilities.

severity: medium

scanner_type: CEL

check_type: Platform

expression: |-
    hco.spec.featureGates.nonRoot == true

inputs:
  - name: hco
    kubernetes_input_spec:
      api_version: hco.kubevirt.io/v1beta1
      resource: hyperconvergeds
      resource_name: kubevirt-hyperconverged
      resource_namespace: openshift-cnv

ocil: |-
    Run the following command to verify the NonRoot feature gate:
    <pre>oc get hyperconverged -n openshift-cnv kubevirt-hyperconverged -o jsonpath='{.spec.featureGates.nonRoot}'</pre>
    The output should be <tt>true</tt>.

references:
    cis@ocp4: 5.7.1
```

## Build System Integration

### Enabling CEL Content for a Product

CEL content generation is enabled per-product in the product's `CMakeLists.txt`:

```cmake
set(PRODUCT "ocp4")
set(PRODUCT_REMEDIATION_LANGUAGES "ignition;kubernetes")
set(PRODUCT_CEL_ENABLED TRUE)  # Enable CEL content generation

ssg_build_product(${PRODUCT})
```

### Build Process

When `PRODUCT_CEL_ENABLED` is set to `TRUE`, the build system:

1. **Compiles all rules** (including CEL rules) using `compile_all.py`
2. **Filters CEL rules** - Rules with `scanner_type: CEL` are identified
3. **Filters CEL profiles** - Profiles with `scanner_type: CEL` are identified
4. **Validates CEL content**:
   - CEL rules must have `expression` field (non-empty)
   - CEL rules must have `inputs` field (non-empty list)
   - CEL profiles must have rules in `selected` field
   - No duplicate rule names after conversion to hyphens
   - Profiles can only reference existing CEL rules
5. **Generates CEL content YAML** at `build/${PRODUCT}-cel-content.yaml`

### Build Script: build_cel_content.py

The `build_cel_content.py` script is located in `build-scripts/` and performs the following:

#### Input
- Resolved rules directory: `build/${PRODUCT}/rules/`
- Resolved profiles directory: `build/${PRODUCT}/profiles/`
- Product YAML: `build/${PRODUCT}/product.yml`

#### Processing
1. Loads all rules with `scanner_type: CEL`
2. Validates required CEL fields (`expression`, `inputs`)
3. Loads all profiles with `scanner_type: CEL`
4. Validates profile rules are non-empty
5. Converts rule IDs (underscores) to rule names (hyphens)
6. Maps `ocil` field to `instructions` in output
7. Preserves reference keys like `cis@ocp4`, `nist`, etc. as `controls`
8. Validates no duplicate rule names
9. Validates all profile rule references exist

#### Output
YAML file at `build/${PRODUCT}-cel-content.yaml` with structure:

```yaml
profiles:
  - id: cis_vm_extension
    name: cis-vm-extension
    title: CIS Red Hat OpenShift Virtual Machine Extension Benchmark
    description: Profile description text
    productType: Platform
    rules:
      - kubevirt-nonroot-feature-gate-is-enabled
      - kubevirt-no-permitted-host-devices

rules:
  - id: kubevirt_nonroot_feature_gate_is_enabled
    name: kubevirt-nonroot-feature-gate-is-enabled
    title: Ensure NonRoot Feature Gate is Enabled
    description: The NonRoot feature gate restricts containers...
    rationale: Running containers as non-root...
    severity: medium
    checkType: Platform
    expression: hco.spec.featureGates.nonRoot == true
    inputs:
      - name: hco
        kubernetesInputSpec:
          apiVersion: hco.kubevirt.io/v1beta1
          resource: hyperconvergeds
          resourceName: kubevirt-hyperconverged
          resourceNamespace: openshift-cnv
    instructions: Run the following command...
    controls:
      cis@ocp4:
        - 5.7.1
```

### Build Targets

```bash
# Build all content including CEL content (for products with PRODUCT_CEL_ENABLED)
./build_product ocp4

# Build data stream only (faster, excludes CEL content)
./build_product ocp4 --datastream
# Short form (only builds datastream):
./build_product ocp4 -d
# Legacy form (still supported):
./build_product ocp4 --datastream-only

# Build data stream and CEL content
./build_product ocp4 --datastream --cel-content=ocp4

# Build only CEL content (no data stream)
./build_product --cel-content=ocp4

# Build CEL content for multiple products
./build_product --cel-content=ocp4,rhel9

# CEL content is generated as build/ocp4-cel-content.yaml
```

## Validation

### Build-Time Validation

The build system validates CEL content automatically:

**Rule Validation:**
- `expression` field must be present and non-empty
- `inputs` field must be present and non-empty list
- Rule directory names must match rule IDs (with hyphens)

**Profile Validation:**
- `selected` field must contain at least one rule
- All selected rules must exist in CEL rules
- Profile cannot reference OVAL rules

**Content Validation:**
- No duplicate rule names (after underscore-to-hyphen conversion)
- All profile rule references must exist

### Manual Validation

Test CEL expressions using the CEL evaluator:

```bash
# Using cel-go
cel-spec '{"resource": {"spec": {"enabled": true}}}' 'resource.spec.enabled == true'
```

## CEL vs OVAL Comparison

| Aspect | CEL | OVAL |
|--------|-----|------|
| **Scope** | Kubernetes API resources | File system, processes, packages |
| **Access Required** | API server access | Node shell access |
| **Syntax** | CEL expressions (C-like) | XML definitions |
| **Performance** | Fast, API-level | Slower, requires node scanning |
| **Use Case** | Platform compliance | OS compliance |
| **Scanner** | compliance-operator | OpenSCAP |
| **Output Format** | YAML (cel-content.yaml) | XML (DataStream) |

## Best Practices

### Writing CEL Rules

1. **Use specific resource names when possible**
   ```yaml
   inputs:
     - name: config
       kubernetes_input_spec:
         api_version: v1
         resource: configmaps
         resource_name: cluster-config  # Specific resource
         resource_namespace: openshift-config
   ```

2. **Check for field existence before accessing**
   ```yaml
   expression: |-
     !has(resource.spec.field) || resource.spec.field == "expected"
   ```

3. **Keep expressions simple and readable**
   - Break complex checks into multiple rules
   - Use clear variable names in inputs
   - Add comments for non-obvious logic

4. **Test expressions thoroughly**
   - Verify both pass and fail cases
   - Test with missing fields
   - Test with unexpected values

### Organizing CEL Rules

1. **Group related rules by component**
   - Use meaningful directory names (e.g., `api-server/`, `kubelet/`)
   - Create a `group.yml` for each component

2. **Follow Kubernetes naming conventions**
   - Use hyphens in directory names
   - Keep names descriptive but concise

3. **Document OCIL instructions**
   - Provide manual verification commands
   - Include expected output
   - Use proper formatting with `<pre>` and `<tt>` tags

## Troubleshooting

### Build Errors

**Error: `CEL rule 'rule-name' has no expression`**
- Add the `expression` field to your rule.yml

**Error: `CEL rule 'rule-name' has no inputs`**
- Add the `inputs` field with at least one Kubernetes input

**Error: `CEL profile 'profile-name' has no rules`**
- Add rules to the `selections` field in the profile

**Error: `profile 'profile-name' references unknown rule 'rule-name'`**
- Verify the rule exists and has `scanner_type: CEL`
- Check the rule ID matches the profile selection

### CEL Content Not Generated

1. Verify `PRODUCT_CEL_ENABLED TRUE` is set in `products/${PRODUCT}/CMakeLists.txt`
2. Check that rules have `scanner_type: CEL`
3. Check that profiles have `scanner_type: CEL`
4. Review build logs for validation errors

## References

- [CEL Language Specification](https://github.com/google/cel-spec)
- [CEL Go Implementation](https://github.com/google/cel-go)
- [Compliance Operator](https://github.com/ComplianceAsCode/compliance-operator)
- [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
