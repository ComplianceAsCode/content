"""Builds a Gemara ControlCatalog from ComplianceAsCode control files.

Framework-agnostic: the control→rule conversion lives here, while everything
that differs between frameworks (ids, grouping, wording, baselines) is supplied
by a :class:`gemara.frameworks.Framework`.  When no framework is given the
builder defaults to NIST 800-53, preserving the original output byte-for-byte.
"""

import re
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import ssg.controls

from .frameworks import NIST_FAMILIES, Framework, NistFramework
from .schema import GEMARA_VERSION
from .status_map import map_state

__all__ = ["GemaraCatalogBuilder", "NIST_FAMILIES"]

_VAR_ASSIGN_RE = re.compile(r'^[a-z][a-z0-9_]*=[^\s]+$')


def _is_variable_assignment(rule_entry: str) -> bool:
    return bool(_VAR_ASSIGN_RE.match(rule_entry))


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
        framework: Optional[Framework] = None,
        version: Optional[str] = None,
    ) -> None:
        self.product = product
        self.policy = policy
        self.framework = framework or NistFramework()
        # Version label: explicit (e.g. from the control file, "V2R9") wins,
        # else the framework default ("Revision 5" for NIST, "" otherwise).
        self.version = version or self.framework.version_label
        self._oscal_index = _build_oscal_index(oscal_catalog)
        # Normalize levels to (level_id, inherits_from) pairs.  Control files
        # with no 'levels:' block get a single synthetic 'all' baseline so the
        # non-empty applicability constraint still holds.
        self._levels = [
            (lv.id, list(lv.inherits_from or [])) for lv in policy.levels
        ] or [("all", [])]
        self._all_baselines = [lid for lid, _ in self._levels]

    # -- metadata -----------------------------------------------------------

    def _metadata(self) -> Dict[str, Any]:
        return {
            "id": self.framework.catalog_id(self.product),
            "type": "ControlCatalog",
            "gemara-version": GEMARA_VERSION,
            "description": self.framework.catalog_description(self.product),
            "author": dict(self.framework.author),
            "version": self.version,
            # #Datetime requires full ISO 8601 with time component
            "date": _now_iso(),
            "applicability-groups": self._applicability_groups(),
        }

    def _applicability_groups(self) -> List[Dict[str, str]]:
        return [
            self.framework.baseline_group(self.product, level_id, inherits)
            for level_id, inherits in self._levels
        ]

    def _groups(self) -> List[Dict[str, str]]:
        return self.framework.groups()

    # -- controls -----------------------------------------------------------

    def _objective(self, control: ssg.controls.Control) -> str:
        """Return objective text: OSCAL statement prose, else title, else id.

        Never returns None: some control files (e.g. STIG) leave titles empty,
        and the Gemara schema requires a non-empty string here.
        """
        ctrl_id = control.id.lower()
        if ctrl_id in self._oscal_index:
            return self._oscal_index[ctrl_id]
        return control.title or control.id

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
        group = self.framework.group_for(control.id)
        cac_status = control.status if control.status else "pending"
        # Gemara requires non-empty title/objective strings; some control files
        # leave the title blank, so fall back to the control id.
        title = control.title or control.id
        return {
            "id": control.id,
            "title": title,
            "objective": self._objective(control) or title,
            "group": group,
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
        """Return one ControlCatalog dict per group (NIST family / section).

        Mirrors the layout complytime-policies splits the combined catalog into
        (one file per group) for a reduced line count and to keep each catalog
        scoped to a single ``groups`` entry.  Groups with no controls are
        omitted.
        """
        # Bucket controls by their resolved group id.
        buckets: Dict[str, List[Dict[str, Any]]] = {}
        for ctrl in self.policy.controls:
            built = self._build_control(ctrl)
            buckets.setdefault(built["group"], []).append(built)

        by_group: Dict[str, Dict[str, Any]] = {}
        for group in self.framework.groups():
            gid = group["id"]
            fam_controls = buckets.get(gid)
            if not fam_controls:
                continue
            by_group[gid] = {
                "metadata": self._metadata_for_group(gid),
                "title": f"{self.policy.title} - {group['title']}",
                "groups": [self.framework.group_meta(gid)],
                "controls": fam_controls,
            }
        return by_group

    def _metadata_for_group(self, group_id: str) -> Dict[str, Any]:
        meta = self._metadata()
        meta["id"] = self.framework.catalog_group_id(self.product, group_id)
        meta["description"] = self.framework.catalog_group_description(
            self.product, group_id
        )
        return meta
