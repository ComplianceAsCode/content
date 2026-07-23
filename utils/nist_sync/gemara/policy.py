"""Gemara Policy builder for NIST 800-53 controls.

Generates a Policy YAML that complyctl uses to drive OpenSCAP scans.
Assessment-plan IDs use SHORT CaC rule names (e.g. 'accounts_tmout');
the OpenSCAP provider adds the xccdf_org.ssgproject.content_rule_ prefix
internally via getDsRuleID().
"""

from datetime import datetime, timezone

from .schema import GEMARA_VERSION

_PRODUCT_FULL_NAMES = {
    "rhel8": "Red Hat Enterprise Linux 8",
    "rhel9": "Red Hat Enterprise Linux 9",
    "rhel10": "Red Hat Enterprise Linux 10",
}


def extract_rules_from_catalog(catalog, baseline=None, product=None):
    """Extract unique XCCDF rule IDs from a ControlCatalog.

    Returns a sorted list of (rule_id, nist_control_ids) tuples where:
      - rule_id is the raw CaC rule ID (e.g. 'accounts_tmout')
      - nist_control_ids is the list of NIST controls that reference this rule
    """
    rule_to_controls = {}
    baseline_key = f"{product}-{baseline}" if (baseline and product) else baseline

    for ctrl in catalog.get("controls", []):
        ctrl_id = ctrl.get("id", "")
        ctrl_state = ctrl.get("state", "")

        if ctrl_state in ("Deprecated", "Retired"):
            continue

        if baseline_key:
            any_in_baseline = False
            for req in ctrl.get("assessment-requirements", []):
                if baseline_key in req.get("applicability", []):
                    any_in_baseline = True
                    break
            if not any_in_baseline:
                continue

        for req in ctrl.get("assessment-requirements", []):
            req_id = req.get("id", "")
            if req_id == "no-automated-check":
                continue
            text = req.get("text", "")
            if text.startswith("Variable '"):
                continue

            rule_id = req_id

            if rule_id not in rule_to_controls:
                rule_to_controls[rule_id] = []
            if ctrl_id not in rule_to_controls[rule_id]:
                rule_to_controls[rule_id].append(ctrl_id)

    return sorted(rule_to_controls.items())


def generate_policy(product, catalog_id, rules_with_controls,
                    guidance_id=None, catalog_url=None, guidance_url=None):
    """Build a Gemara Policy YAML dict.

    Args:
        product: Product ID (e.g. 'rhel9').
        catalog_id: The ControlCatalog metadata.id to reference.
        rules_with_controls: Output of extract_rules_from_catalog().
        guidance_id: Optional GuidanceCatalog ID to import.
        catalog_url: Optional file:// URL for the catalog mapping-reference.
        guidance_url: Optional file:// URL for the guidance mapping-reference.

    When catalog_url/guidance_url are provided (complytime-policies mode),
    the Policy includes relative file:// URLs in mapping-references and an
    imports.guidance section.  When omitted (local Vagrant mode), those
    fields are absent — matching the existing local-push behavior.
    """
    full_name = _PRODUCT_FULL_NAMES.get(product, product.upper())
    policy_id = f"nist-800-53-rev5-{product}-policy"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    assessment_plans = []
    for rule_id, _nist_controls in rules_with_controls:
        assessment_plans.append({
            "id": rule_id,
            "requirement-id": rule_id,
            "frequency": "on-demand",
            "evaluation-methods": [
                {
                    "id": "openscap-automated",
                    "type": "Behavioral",
                    "mode": "Automated",
                }
            ],
        })

    mapping_refs = [
        {
            "id": catalog_id,
            "title": f"NIST SP 800-53 Rev 5 Control Catalog for {product.upper()}",
            "version": "Revision 5",
            "url": catalog_url or "https://github.com/ComplianceAsCode/content",
        }
    ]
    if guidance_id:
        ref = {
            "id": guidance_id,
            "title": "NIST SP 800-53 Rev 5 Guidance Catalog",
            "version": "Revision 5",
        }
        if guidance_url:
            ref["url"] = guidance_url
        mapping_refs.append(ref)

    imports = {
        "catalogs": [{"reference-id": catalog_id}],
    }
    if guidance_id:
        imports["guidance"] = [{"reference-id": guidance_id}]

    return {
        "title": f"NIST SP 800-53 Rev 5 for {full_name}",
        "metadata": {
            "id": policy_id,
            "type": "Policy",
            "gemara-version": GEMARA_VERSION,
            "description": (
                f"Automated evaluation policy for NIST SP 800-53 Rev 5 on {full_name}, "
                "using ComplianceAsCode rules. requirement-id values are short CaC rule names "
                "(the OpenSCAP provider adds the xccdf_org.ssgproject.content_rule_ prefix)."
            ),
            "author": {
                "id": "complianceascode",
                "name": "ComplianceAsCode Project",
                "type": "Software",
                "uri": "https://github.com/ComplianceAsCode/content",
            },
            "date": now_iso,
            "mapping-references": mapping_refs,
        },
        "contacts": {
            "responsible": [{"name": "System Administrator"}],
            "accountable": [{"name": "Security Team"}],
        },
        "scope": {
            "in": {
                "technologies": [full_name],
            }
        },
        "imports": imports,
        "adherence": {
            "evaluation-methods": [
                {
                    "id": "openscap-automated",
                    "type": "Behavioral",
                    "mode": "Automated",
                    "description": "OpenSCAP automated compliance evaluation",
                    "executor": {
                        "id": "openscap",
                        "name": "OpenSCAP",
                        "type": "Software",
                    },
                }
            ],
            "assessment-plans": assessment_plans,
        },
    }
