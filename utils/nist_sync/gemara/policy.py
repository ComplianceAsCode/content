"""Gemara Policy builder for NIST 800-53 controls.

Generates a Policy YAML that complyctl uses to drive OpenSCAP scans.
Assessment-plan IDs use SHORT CaC rule names (e.g. 'accounts_tmout');
the OpenSCAP provider adds the xccdf_org.ssgproject.content_rule_ prefix
internally via getDsRuleID().
"""

import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import ssg.products

from .schema import GEMARA_VERSION

_REPO_ROOT = Path(__file__).resolve().parents[3]
_RULE_SEARCH_DIRS = ("linux_os/guide",)
_VARIABLE_VALUE_RE = re.compile(r"^Variable '.*' is set to '(.*)'$")

# (rule_id, nist_control_ids, [(var_name, var_value), ...])
RuleEntry = Tuple[str, List[str], List[Tuple[str, str]]]

_rule_content_cache: Optional[Dict[str, str]] = None


def _rule_content_index() -> Dict[str, str]:
    """Lazily build and cache a rule_id -> rule.yml text index.

    Used to tell which sibling rule in a control actually reads a given
    control-file variable (e.g. 'var_audit_backlog_limit'), since CaC
    control files list rules and variable assignments as flat siblings
    with no explicit pairing between them.
    """
    global _rule_content_cache
    if _rule_content_cache is None:
        index: Dict[str, str] = {}
        for rel_dir in _RULE_SEARCH_DIRS:
            base = _REPO_ROOT / rel_dir
            if not base.is_dir():
                continue
            for rule_yml in base.rglob("rule.yml"):
                index[rule_yml.parent.name] = rule_yml.read_text(encoding="utf-8", errors="ignore")
        _rule_content_cache = index
    return _rule_content_cache


def product_full_name(product: str) -> str:
    """Return a product's display name (e.g. 'Red Hat Enterprise Linux 9') from its product.yml."""
    yaml_path = ssg.products.product_yaml_path(str(_REPO_ROOT), product)
    return ssg.products.load_product_yaml(yaml_path)["full_name"]


def _humanize_var_name(var_name: str) -> str:
    name = var_name
    if name.startswith("var_"):
        name = name[len("var_"):]
    if name.endswith("_value"):
        name = name[: -len("_value")]
    return name.replace("_", " ").strip().title() or var_name


def extract_rules_from_catalog(
    catalog: Dict[str, Any],
    baseline: Optional[str] = None,
    product: Optional[str] = None,
) -> List[RuleEntry]:
    """Extract unique XCCDF rule IDs from a ControlCatalog.

    Returns a sorted list of (rule_id, nist_control_ids, parameters) tuples where:
      - rule_id is the raw CaC rule ID (e.g. 'accounts_tmout')
      - nist_control_ids is the list of NIST controls that reference this rule
      - parameters is a sorted list of (var_name, var_value) tuples for control-file
        variable overrides whose rule.yml references var_name (empty if none apply)
    """
    rule_to_controls: Dict[str, List[str]] = {}
    rule_to_parameters: Dict[str, Dict[str, str]] = {}
    baseline_key = f"{product}-{baseline}" if (baseline and product) else baseline
    rule_index = _rule_content_index()

    for ctrl in catalog.get("controls", []):
        ctrl_id = ctrl.get("id", "")
        ctrl_state = ctrl.get("state", "")

        if ctrl_state in ("Deprecated", "Retired"):
            continue

        reqs = ctrl.get("assessment-requirements", [])

        if baseline_key:
            any_in_baseline = False
            for req in reqs:
                if baseline_key in req.get("applicability", []):
                    any_in_baseline = True
                    break
            if not any_in_baseline:
                continue

        control_variables = []
        for req in reqs:
            value = _VARIABLE_VALUE_RE.match(req.get("text", ""))
            if value:
                control_variables.append((req.get("id", ""), value.group(1)))

        for req in reqs:
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

            if control_variables:
                rule_content = rule_index.get(rule_id, "")
                for var_name, var_value in control_variables:
                    if var_name and var_name in rule_content:
                        rule_to_parameters.setdefault(rule_id, {})[var_name] = var_value

    return sorted(
        (rule_id, controls, sorted(rule_to_parameters.get(rule_id, {}).items()))
        for rule_id, controls in rule_to_controls.items()
    )


def generate_policy(
    product: str,
    catalog_id: str,
    rules_with_controls: List[RuleEntry],
    guidance_id: Optional[str] = None,
    catalog_url: Optional[str] = None,
    guidance_url: Optional[str] = None,
) -> Dict[str, Any]:
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
    full_name = product_full_name(product)
    policy_id = f"nist-800-53-rev5-{product}-policy"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    assessment_plans = []
    for rule_id, _nist_controls, parameters in rules_with_controls:
        plan = {
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
        }
        if parameters:
            plan["parameters"] = [
                {
                    "id": var_name,
                    "label": _humanize_var_name(var_name),
                    "description": f"ComplianceAsCode sets {var_name} to {var_value!r} for this control.",
                    "accepted-values": [var_value],
                }
                for var_name, var_value in parameters
            ]
        assessment_plans.append(plan)

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
