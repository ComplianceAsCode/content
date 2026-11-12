"""Profile-driven Gemara export.

The authoritative "what a profile selects" is the *resolved* profile the build
emits at ``build/<product>/profiles/<name>.profile`` — a JSON document whose
``selections`` list has ``extends``, unselects (``!rule``) and ``var=value``
overrides already applied.  Driving the Gemara **Policy** from this (rather than
from the raw control file) means every shipped customization is captured
faithfully: an unselected rule is simply absent from the assessment-plans, and a
profile's variable choices become assessment-plan ``parameters``.

Catalog selection:
  * the resolved profile's ``policies`` field names the backing control file(s);
    that control file's ControlCatalog is used (universe), and the Policy scopes
    the subset the profile actually selects.
  * a profile with no control file (``policies: []``) uses a shared per-product
    generic "all-rules" catalog (see :class:`AllRulesCatalogBuilder`).
"""

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from .frameworks import COMPLIANCEASCODE_AUTHOR, Framework, product_display
from .policy import _humanize_var_name, _rule_content_index  # reuse pairing helpers
from .schema import GEMARA_VERSION

# (rule_id, [(var_name, var_value), ...])
ProfileRuleEntry = Tuple[str, List[Tuple[str, str]]]


def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sanitize_id(name: str) -> str:
    """Kubernetes-style id: lowercase, underscores -> hyphens."""
    return name.replace("_", "-").lower()


class ResolvedProfile:
    """A parsed resolved profile (build/<product>/profiles/<name>.profile)."""

    def __init__(self, name: str, data: Dict[str, Any]) -> None:
        self.name = name
        self.title: str = data.get("title") or name
        self.description: str = data.get("description") or ""
        self.policies: List[str] = list(data.get("policies") or [])
        self.scanner_type = data.get("scanner_type")
        self.hidden = bool(data.get("hidden"))
        meta = data.get("metadata") or {}
        self.version: str = str(meta.get("version") or "")
        rules: List[str] = []
        variables: List[Tuple[str, str]] = []
        for sel in data.get("selections") or []:
            if not isinstance(sel, str):
                continue
            if sel.startswith("!"):
                continue  # already-applied unselect (defensive)
            if "=" in sel:
                k, v = sel.split("=", 1)
                variables.append((k, v))
            else:
                rules.append(sel)
        # de-dup, preserve order
        self.rules: List[str] = list(dict.fromkeys(rules))
        self.variables: List[Tuple[str, str]] = variables


def read_resolved_profile(path: Path) -> ResolvedProfile:
    """Parse a resolved profile JSON file produced by the build."""
    with open(path) as f:
        data = json.load(f)
    return ResolvedProfile(path.stem, data)


def pair_vars_to_rules(
    rules: List[str], variables: List[Tuple[str, str]]
) -> List[ProfileRuleEntry]:
    """Attach each profile variable to the selected rules whose rule.yml uses it.

    Mirrors the control-file pairing in gemara.policy: CaC lists rules and
    variables as flat siblings, so we pair them by scanning rule.yml content.
    """
    idx = _rule_content_index()
    out: List[ProfileRuleEntry] = []
    for rule_id in rules:
        content = idx.get(rule_id, "")
        params = sorted(
            (var, val) for (var, val) in variables if var and var in content
        )
        out.append((rule_id, params))
    return out


def generate_profile_policy(
    product: str,
    full_name: str,
    resolved: ResolvedProfile,
    catalog_id: str,
    catalog_url: Optional[str],
    framework: Framework,
    rules_with_params: List[ProfileRuleEntry],
    version: Optional[str] = None,
) -> Dict[str, Any]:
    """Build a Gemara Policy dict for one resolved profile.

    policy id = ``<product>-<profile>-policy`` (hyphenated); assessment-plans are
    the profile's effective rules; parameters are the profile's variable choices.

    ``version`` labels the catalog mapping-reference. Callers should pass the
    referenced catalog's ``metadata.version`` so the Policy never advertises a
    different benchmark version than the catalog it imports (the resolved
    profile's own ``metadata.version`` can lag a rebuilt control file). When
    ``None``, fall back to the resolved profile's version.
    """
    policy_id = f"{sanitize_id(product)}-{sanitize_id(resolved.name)}-policy"
    if version is None:
        version = resolved.version or framework.version_label

    assessment_plans: List[Dict[str, Any]] = []
    for rule_id, params in rules_with_params:
        plan: Dict[str, Any] = {
            "id": rule_id,
            "requirement-id": rule_id,
            "frequency": "on-demand",
            "evaluation-methods": [
                {"id": "openscap-automated", "type": "Behavioral", "mode": "Automated"}
            ],
        }
        if params:
            plan["parameters"] = [
                {
                    "id": var,
                    "label": _humanize_var_name(var),
                    "description": f"Profile '{resolved.name}' sets {var} to {val!r}.",
                    "accepted-values": [val],
                }
                for var, val in params
            ]
        assessment_plans.append(plan)

    mapping_ref = {
        "id": catalog_id,
        "title": f"{framework.short_name} Control Catalog for {product_display(product)}",
        "version": version,
        "url": catalog_url or "https://github.com/ComplianceAsCode/content",
    }

    return {
        "title": resolved.title,
        "metadata": {
            "id": policy_id,
            "type": "Policy",
            "gemara-version": GEMARA_VERSION,
            "description": (
                f"Automated evaluation policy for the '{resolved.name}' profile on "
                f"{full_name}, generated from the resolved ComplianceAsCode profile. "
                "requirement-id values are short CaC rule names (the OpenSCAP "
                "provider adds the xccdf_org.ssgproject.content_rule_ prefix)."
            ),
            "author": dict(COMPLIANCEASCODE_AUTHOR),
            "date": _now_iso(),
            "mapping-references": [mapping_ref],
        },
        "contacts": {
            "responsible": [{"name": "System Administrator"}],
            "accountable": [{"name": "Security Team"}],
        },
        "scope": {"in": {"technologies": [full_name]}},
        "imports": {"catalogs": [{"reference-id": catalog_id}]},
        "adherence": {
            "evaluation-methods": [
                {
                    "id": "openscap-automated",
                    "type": "Behavioral",
                    "mode": "Automated",
                    "description": "OpenSCAP automated compliance evaluation",
                    "executor": {"id": "openscap", "name": "OpenSCAP", "type": "Software"},
                }
            ],
            "assessment-plans": assessment_plans,
        },
    }


class AllRulesCatalogBuilder:
    """Shared per-product generic ControlCatalog: one control per rule.

    Used by profiles that have no backing control file.  Every rule in the
    product's rule universe becomes a 1:1 control/requirement, so any
    frameworkless profile can import this one catalog and select its subset via
    assessment-plans.
    """

    def __init__(self, product: str, rule_ids: List[str], version: str = "") -> None:
        self.product = product
        self.rule_ids = list(dict.fromkeys(rule_ids))
        self.version = version

    def catalog_id(self) -> str:
        return f"{sanitize_id(self.product)}-rules"

    def _metadata(self) -> Dict[str, Any]:
        return {
            "id": self.catalog_id(),
            "type": "ControlCatalog",
            "gemara-version": GEMARA_VERSION,
            "description": (
                f"Generic rule catalog for {product_display(self.product)}: every "
                "ComplianceAsCode rule as a standalone control. Backs profiles "
                "that are not derived from a framework control file."
            ),
            "author": dict(COMPLIANCEASCODE_AUTHOR),
            "version": self.version,
            "date": _now_iso(),
            "applicability-groups": [
                {
                    "id": f"{self.product}-all",
                    "title": f"{product_display(self.product)} (all rules)",
                    "description": f"All ComplianceAsCode rules for {product_display(self.product)}",
                }
            ],
        }

    def build(self) -> Dict[str, Any]:
        app = [f"{self.product}-all"]
        controls = [
            {
                "id": rule_id,
                "title": rule_id,
                "objective": f"Rule '{rule_id}' is satisfied",
                "group": "rules",
                "state": "Active",
                "assessment-requirements": [
                    {
                        "id": rule_id,
                        "state": "Active",
                        "text": f"Rule '{rule_id}' MUST be verified",
                        "applicability": app,
                    }
                ],
            }
            for rule_id in self.rule_ids
        ]
        return {
            "metadata": self._metadata(),
            "title": f"ComplianceAsCode Rules for {product_display(self.product)}",
            "groups": [
                {
                    "id": "rules",
                    "title": "Rules",
                    "description": "All ComplianceAsCode rules for the product",
                }
            ],
            "controls": controls,
        }
