---
disable-model-invocation: true
---

Search for existing rules that match the following requirement:

$ARGUMENTS

Follow these steps:

1. **Extract key concepts** from the requirement text. Identify:
   - Technical terms (e.g., "TLS", "audit", "encryption", "RBAC")
   - Component references (e.g., "API server", "kubelet", "etcd", "SSH")
   - Specific settings or parameters mentioned
   - Any reference IDs (SRG-xxx, CIS section numbers, STIG IDs, NIST controls)

2. **Respect scope constraints.** If the user specifies a scope (e.g., "only OpenShift control plane", "only node-level"), restrict results to that scope. Do not return rules outside the requested scope. OCP4/Kubernetes rules live under `applications/openshift/` and Linux rules live under `linux_os/guide/`. If no scope is specified, search both.

3. **Search broadly** across rule titles, descriptions, and template configurations:
   - Search `applications/openshift/` and `linux_os/guide/` for `rule.yml` files
   - Search for keywords in titles, descriptions, template vars, and reference fields
   - If reference IDs were provided, search for those exact IDs in rule.yml files

4. **Check control files** in `controls/` and `products/*/controls/` for matching control IDs or titles that already map to this requirement.

5. **Note product applicability** for each matched rule. Check the `identifiers` section of each rule.yml for `cce@<product>` entries (e.g., `cce@ocp4`, `cce@rhel9`). The product IDs after `@` correspond to subdirectory names under `products/`. This tells the user which products the rule applies to.

6. **Present results** organized by match strength. For every rule, include a **Rationale** — a concise (1-2 sentence) explanation of why this rule satisfies or partially satisfies the requirement. Write the rationale so that a maintainer unfamiliar with the rule can understand the connection without reading the full rule.yml. Focus on *what the rule checks* and *how that maps to the requirement*.

   **Strong matches** (title or template directly addresses the requirement):
   - Rule ID, file path, title, severity
   - Template type and key vars (if templated)
   - Matching references (SRG, CIS, STIG, NIST)
   - Product applicability (which products have CCE identifiers)
   - Whether the rule has an automated template or is manual review only
   - **Rationale:** Why this rule is a strong match for the requirement

   **Partial matches** (related but not exact):
   - Same fields as above
   - **Rationale:** What aspect of the requirement this rule covers and what it does not

   **Weak matches** (tangentially related):
   - Rule ID, file path, title
   - **Rationale:** Why it was included despite being tangential

7. **Include a summary table** at the end mapping requirement aspects to rule IDs, so the user can quickly see coverage.

8. **Always suggest a control structure** with a `notes` field that includes a concise rationale for each rule, explaining why it was included for this control. This helps maintainers understand the reasoning without needing to read every rule.yml. When no strong automated matches exist, say so clearly and use `status: partial` or `status: manual` as appropriate. Example:

   ```yaml
   - id: X.Y.Z
     title: Control Title
     status: automated
     notes: |-
         automated_rule_1 - Rationale for why this rule satisfies the control.
         automated_rule_2 - Rationale for why this rule satisfies the control.
     rules:
         - automated_rule_1
         - automated_rule_2
   ```

   For partial or manual controls, also include guidance for assessors:

   ```yaml
   - id: X.Y.Z
     title: Control Title
     status: partial
     notes: |-
         automated_rule_1 - Rationale for why this rule partially covers the control.
         The remaining aspects of this control require manual verification: [manual steps].
     rules:
         - automated_rule_1
   ```

   When suggesting rules for partial/manual controls, only include rules that provide automated value. Omit rules that are themselves manual-only (no template, no automated check) unless they are the only matches available.

9. **Rules can appear in multiple controls.** The build system handles this correctly. Each control should list the complete set of rules needed to satisfy it, even if some rules also appear in other controls. This ensures each control is self-contained and readers don't need to cross-reference other controls to understand coverage.
