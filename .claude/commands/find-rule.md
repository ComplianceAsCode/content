Search for existing rules that match the following requirement:

$ARGUMENTS

Follow these steps:

1. **Extract key concepts** from the requirement text. Identify:
   - Technical terms (e.g., "TLS", "audit", "encryption", "RBAC")
   - Component references (e.g., "API server", "kubelet", "etcd", "SSH")
   - Specific settings or parameters mentioned
   - Any reference IDs (SRG-xxx, CIS section numbers, STIG IDs, NIST controls)

2. **Respect scope constraints.** If the user specifies a scope (e.g., "only OpenShift control plane", "only RHCOS", "only Kubernetes"), restrict results to that scope. Do not return rules outside the requested scope. Common scopes:
   - OCP4/Kubernetes: `applications/openshift/`
   - RHEL/RHCOS (node-level): `linux_os/guide/`
   - If no scope is specified, search both.

3. **Search broadly** across rule titles, descriptions, and template configurations:
   - Search `applications/openshift/` for OCP4/Kubernetes rules
   - Search `linux_os/guide/` for Linux rules (RHEL, RHCOS, Fedora, Amazon Linux, SUSE, Oracle Linux, etc.)
   - Search for keywords in `rule.yml` files: titles, descriptions, template vars, and reference fields
   - If reference IDs were provided, search for those exact IDs in rule.yml files

4. **Check control files** in `controls/` and `products/*/controls/` for matching control IDs or titles that already map to this requirement.

5. **Note product applicability** for each matched rule. Check the `identifiers` section of each rule.yml for `cce@ocp4`, `cce@rhcos4`, `cce@rhel9`, etc. This tells the user which products the rule applies to, which matters when building multi-product profiles (e.g., a control file with `product: [ocp4, rhcos4]`).

6. **Present results** organized by match strength:

   **Strong matches** (title or template directly addresses the requirement):
   - Rule ID, file path, title, severity
   - Template type and key vars (if templated)
   - Matching references (SRG, CIS, STIG, NIST)
   - Product applicability (which products have CCE identifiers)
   - Whether the rule has an automated template or is manual review only
   - Why this is a strong match

   **Partial matches** (related but not exact):
   - Same fields as above
   - What aspect matches and what differs

   **Weak matches** (tangentially related):
   - Rule ID, file path, title
   - Why it was included

7. **Include a summary table** at the end mapping requirement aspects to rule IDs, so the user can quickly see coverage.

8. **When no strong automated matches exist**, say so clearly. Suggest a control structure using `status: partial` (if some automated rules provide partial coverage) or `status: manual` (if the requirement is entirely an infrastructure/organizational concern). Include a `notes` field with guidance for assessors. Example:

   ```yaml
   - id: X.Y.Z
     title: Control Title
     status: partial
     notes: |-
         This is an infrastructure-level control. Verify that [manual steps].
     rules:
         - automated_rule_1
         - automated_rule_2
   ```

   When suggesting rules for partial/manual controls, only include rules that provide automated value. Omit rules that are themselves manual-only (no template, no automated check) unless they are the only matches available.

9. **Rules can appear in multiple controls.** The build system handles this correctly (see `stig_ocp4.yml` for precedent). Each control should list the complete set of rules needed to satisfy it, even if some rules also appear in other controls. This ensures each control is self-contained and readers don't need to cross-reference other controls to understand coverage.
