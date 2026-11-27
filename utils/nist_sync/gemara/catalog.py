"""Builds a Gemara ControlCatalog from ComplianceAsCode NIST 800-53 controls."""

import re
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import ssg.controls

from .schema import GEMARA_VERSION
from .status_map import map_state

# NIST 800-53 Rev 5 control families (matches sync_nist_split.py)
NIST_FAMILIES = {
    'ac': 'Access Control',
    'at': 'Awareness and Training',
    'au': 'Audit and Accountability',
    'ca': 'Assessment, Authorization, and Monitoring',
    'cm': 'Configuration Management',
    'cp': 'Contingency Planning',
    'ia': 'Identification and Authentication',
    'ir': 'Incident Response',
    'ma': 'Maintenance',
    'mp': 'Media Protection',
    'pe': 'Physical and Environmental Protection',
    'pl': 'Planning',
    'pm': 'Program Management',
    'ps': 'Personnel Security',
    'pt': 'PII Processing and Transparency',
    'ra': 'Risk Assessment',
    'sa': 'System and Services Acquisition',
    'sc': 'System and Communications Protection',
    'si': 'System and Information Integrity',
    'sr': 'Supply Chain Risk Management',
}

_VAR_ASSIGN_RE = re.compile(r'^[a-z][a-z0-9_]*=[^\s]+$')


def _is_variable_assignment(rule_entry: str) -> bool:
    return bool(_VAR_ASSIGN_RE.match(rule_entry))


def _extract_family(control_id: str) -> str:
    return control_id.split('-')[0].lower()


def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _build_oscal_index(oscal_catalog: Optional[Dict[str, Any]]) -> Dict[str, str]:
    """Build a dict mapping lowercase control IDs to their statement prose."""
    index: Dict[str, str] = {}
    if not oscal_catalog:
        return index
    catalog = oscal_catalog.get("catalog", {})
    for group in catalog.get("groups", []):
        for ctrl in group.get("controls", []):
            _index_control(ctrl, index)
    return index


def _index_control(ctrl: Dict[str, Any], index: Dict[str, str]) -> None:
    ctrl_id = ctrl.get("id", "").lower()
    prose = ""
    for part in ctrl.get("parts", []):
        if part.get("name") == "statement":
            prose = part.get("prose", "").strip()
            if not prose:
                sub_parts = [p.get("prose", "").strip() for p in part.get("parts", [])]
                prose = " ".join(p for p in sub_parts if p)
            break
    if ctrl_id and prose:
        index[ctrl_id] = prose
    for enhancement in ctrl.get("controls", []):
        _index_control(enhancement, index)


class GemaraCatalogBuilder:
    """Builds a Gemara ControlCatalog dict from a loaded CaC Policy object."""

    def __init__(
        self,
        product: str,
        policy: ssg.controls.Policy,
        oscal_catalog: Optional[Dict[str, Any]] = None,
    ) -> None:
        self.product = product
        self.policy = policy
        self._oscal_index = _build_oscal_index(oscal_catalog)
        # Collect all baseline IDs for use as default applicability
        self._all_baselines = [lv.id for lv in policy.levels]

    def _metadata(self) -> Dict[str, Any]:
        catalog_id = f"nist-800-53-rev5-{self.product}"
        return {
            "id": catalog_id,
            "type": "ControlCatalog",
            "gemara-version": GEMARA_VERSION,
            "description": (
                f"NIST Special Publication 800-53 Revision 5 controls for "
                f"{self.product.upper()}, generated from ComplianceAsCode"
            ),
            "author": {
                "id": "complianceascode",
                "name": "ComplianceAsCode Project",
                "type": "Software",
                "uri": "https://github.com/ComplianceAsCode/content",
            },
            "version": "Revision 5",
            # #Datetime requires full ISO 8601 with time component
            "date": _now_iso(),
            "applicability-groups": self._applicability_groups(),
        }

    def _applicability_groups(self) -> List[Dict[str, str]]:
        groups = []
        for level in self.policy.levels:
            group_id = f"{self.product}-{level.id}"
            desc = f"NIST 800-53 {level.id.capitalize()} impact baseline for {self.product.upper()}"
            if level.inherits_from:
                parents = ", ".join(p.capitalize() for p in level.inherits_from)
                desc += f" (inherits {parents})"
            groups.append({
                "id": group_id,
                "title": f"{self.product.upper()} {level.id.capitalize()} Baseline",
                "description": desc,
            })
        return groups

    def _groups(self) -> List[Dict[str, str]]:
        return [
            {
                "id": fam_id,
                "title": fam_title,
                "description": f"NIST 800-53 {fam_id.upper()} family: {fam_title}",
            }
            for fam_id, fam_title in NIST_FAMILIES.items()
        ]

    def _objective(self, control: ssg.controls.Control) -> str:
        """Return objective text: OSCAL statement prose, or title as fallback."""
        ctrl_id = control.id.lower()
        if ctrl_id in self._oscal_index:
            return self._oscal_index[ctrl_id]
        return control.title

    def _applicability_for(self, control: ssg.controls.Control) -> List[str]:
        """Return non-empty product-scoped applicability list for a control."""
        seen = set()
        deduped = []
        for level in (control.levels or []):
            scoped = f"{self.product}-{level}"
            if scoped not in seen:
                seen.add(scoped)
                deduped.append(scoped)
        # applicability must be non-empty: fall back to all baselines
        return deduped if deduped else [f"{self.product}-{b}" for b in self._all_baselines]

    def _assessment_requirements(self, control: ssg.controls.Control) -> List[Dict[str, Any]]:
        """
        Convert control.rules to Gemara assessment requirements.

        If the control has no rules, returns a single placeholder requirement
        so that the non-empty constraint on assessment-requirements is satisfied.
        """
        applicability = self._applicability_for(control)
        reqs = []
        seen_req_ids = set()

        for rule_entry in (control.rules or []):
            if _is_variable_assignment(rule_entry):
                var_name, var_value = rule_entry.split("=", 1)
                req_id = var_name
                req_text = f"Variable '{var_name}' is set to '{var_value}'"
            else:
                req_id = rule_entry
                req_text = f"Rule '{rule_entry}' MUST be verified"

            if req_id in seen_req_ids:
                continue
            seen_req_ids.add(req_id)

            reqs.append({
                "id": req_id,
                "state": "Active",
                "text": req_text,
                "applicability": applicability,
            })

        if not reqs:
            cac_status = control.status if control.status else "pending"
            reqs.append({
                "id": "no-automated-check",
                "state": "Active",
                "text": (
                    f"This control has no automated checks. "
                    f"ComplianceAsCode status: {cac_status}. Manual assessment required."
                ),
                "applicability": applicability,
            })

        return reqs

    def _build_control(self, control: ssg.controls.Control) -> Dict[str, Any]:
        family = _extract_family(control.id)
        if family not in NIST_FAMILIES:
            family = list(NIST_FAMILIES.keys())[0]  # fallback to first family
        cac_status = control.status if control.status else "pending"
        return {
            "id": control.id,
            "title": control.title,
            "objective": self._objective(control),
            "group": family,
            "assessment-requirements": self._assessment_requirements(control),
            # #Lifecycle: "Active" | "Draft" | "Deprecated" | "Retired"
            "state": map_state(cac_status),
        }

    def build(self) -> Dict[str, Any]:
        """Return a complete ControlCatalog dict ready for serialization."""
        controls = [self._build_control(ctrl) for ctrl in self.policy.controls]
        return {
            "metadata": self._metadata(),
            "title": self.policy.title,
            "groups": self._groups(),
            "controls": controls,
        }

    def build_by_group(self) -> Dict[str, Dict[str, Any]]:
        """Return one ControlCatalog dict per NIST 800-53 family/group.

        Mirrors the layout complytime-policies splits the combined catalog
        into (one file per family, e.g. AC, AU, SI) for a reduced line count
        and to keep each catalog scoped to a single 'groups' entry.
        """
        by_group: Dict[str, Dict[str, Any]] = {}
        for fam_id, fam_title in NIST_FAMILIES.items():
            fam_controls = [
                self._build_control(ctrl)
                for ctrl in self.policy.controls
                if _extract_family(ctrl.id) == fam_id
            ]
            if not fam_controls:
                continue
            by_group[fam_id] = {
                "metadata": self._metadata_for_group(fam_id),
                "title": f"{self.policy.title} - {fam_title}",
                "groups": [{
                    "id": fam_id,
                    "title": fam_title,
                    "description": f"NIST 800-53 {fam_id.upper()} family: {fam_title}",
                }],
                "controls": fam_controls,
            }
        return by_group

    def _metadata_for_group(self, fam_id: str) -> Dict[str, Any]:
        meta = self._metadata()
        meta["id"] = f"nist-800-53-rev5-{self.product}-{fam_id}"
        meta["description"] = (
            f"NIST Special Publication 800-53 Revision 5 controls for "
            f"{self.product.upper()}, generated from ComplianceAsCode "
            f"({fam_id.upper()} family)"
        )
        return meta
