"""Builds a Gemara GuidanceCatalog from the NIST 800-53 Rev 5 OSCAL catalog.

The GuidanceCatalog is the abstract "what should be" layer — it contains the
official NIST 800-53 control text (objectives, statements, guidance prose)
independent of any particular platform or implementation.

Sources:
  - OSCAL catalog: utils/nist_sync/data/nist_800_53_rev5_catalog.json
  - Baseline profiles: utils/nist_sync/data/nist_800_53_rev5_{low,moderate,high}_baseline.json
"""

import json
import re
from datetime import datetime, timezone
from pathlib import Path

from .catalog import NIST_FAMILIES
from .schema import GEMARA_VERSION

BASELINES = ["low", "moderate", "high"]


def _load_json(path):
    with open(path) as f:
        return json.load(f)


def _build_baseline_index(data_dir):
    """Return dict mapping control_id (lowercase) -> list of applicable baseline IDs."""
    index = {}
    for baseline in BASELINES:
        path = Path(data_dir) / f"nist_800_53_rev5_{baseline}_baseline.json"
        if not path.exists():
            continue
        data = _load_json(path)
        for imp in data["profile"].get("imports", []):
            for incl in imp.get("include-controls", []):
                for ctrl_id in incl.get("with-ids", []):
                    ctrl_id = ctrl_id.lower()
                    if ctrl_id not in index:
                        index[ctrl_id] = []
                    index[ctrl_id].append(baseline)
    return index


def _build_param_index(ctrl, parent_params=None):
    """Build param_id -> label dict for {{ insert: param, ... }} substitution."""
    index = dict(parent_params) if parent_params else {}
    for param in ctrl.get("params", []):
        pid = param.get("id", "")
        label = param.get("label", "")
        if not label:
            select = param.get("select", {})
            if isinstance(select, dict):
                choices = select.get("choice", [])
                label = " or ".join(c for c in choices if isinstance(c, str))
        index[pid] = label or pid
    return index


_PARAM_RE = re.compile(r"\{\{\s*insert:\s*param,\s*([^}]+?)\s*\}\}")


def _sub_params(text, param_index):
    """Replace OSCAL {{ insert: param, ID }} markers with human-readable labels."""
    def replacer(m):
        pid = m.group(1).strip()
        return param_index.get(pid, f"[{pid}]")
    return _PARAM_RE.sub(replacer, text)


def _collect_part_prose(parts, name, param_index):
    """Return prose from the first part matching name, substituting params."""
    for part in parts:
        if part.get("name") != name:
            continue
        prose = part.get("prose", "").strip()
        if prose:
            return _sub_params(prose, param_index)
        # Empty top-level prose: join sub-part items
        items = [
            _sub_params(sp.get("prose", "").strip(), param_index)
            for sp in part.get("parts", [])
            if sp.get("prose", "").strip()
        ]
        return " ".join(items)
    return ""


def _build_statements(parts, ctrl_id, param_index):
    """Build Gemara Statement list from OSCAL statement sub-parts."""
    statements = []
    for part in parts:
        if part.get("name") != "statement":
            continue
        top_prose = part.get("prose", "").strip()
        if top_prose:
            statements.append({
                "id": f"{ctrl_id}--stmt",
                "text": _sub_params(top_prose, param_index),
            })
        else:
            for i, sp in enumerate(part.get("parts", []), 1):
                sp_prose = sp.get("prose", "").strip()
                if sp_prose:
                    statements.append({
                        "id": f"{ctrl_id}--stmt-{i}",
                        "text": _sub_params(sp_prose, param_index),
                    })
    return statements


def _build_guideline(ctrl, family_id, param_index, baseline_index, all_baselines):
    """Convert one OSCAL control to a Gemara Guideline dict."""
    ctrl_id = ctrl["id"].lower()
    parts = ctrl.get("parts", [])

    # Objective: statement prose (verbatim NIST text), fall back to title
    objective = _collect_part_prose(parts, "statement", param_index)
    if not objective:
        objective = ctrl.get("title", ctrl_id)

    # Applicability: which baselines include this control
    applicability = baseline_index.get(ctrl_id)

    # Detailed statements from OSCAL statement sub-parts
    statements = _build_statements(parts, ctrl_id, param_index)

    # Rationale from OSCAL guidance prose
    guidance_prose = _collect_part_prose(parts, "guidance", param_index)

    guideline = {
        "id": ctrl_id,
        "title": ctrl["title"],
        "objective": objective,
        "group": family_id,
        "state": "Active",
    }

    if applicability:
        guideline["applicability"] = applicability

    if statements:
        guideline["statements"] = statements

    if guidance_prose:
        guideline["rationale"] = {
            "importance": guidance_prose,
            "goals": [f"Satisfy NIST 800-53 Rev 5 control {ctrl_id.upper()}"],
        }

    return guideline


def _now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


class GemaraGuidanceCatalogBuilder:
    """Builds a Gemara GuidanceCatalog from the NIST 800-53 OSCAL catalog."""

    def __init__(self, oscal_catalog, data_dir=None):
        """
        Args:
            oscal_catalog: Parsed OSCAL catalog dict (top-level with 'catalog' key,
                           or already the inner 'catalog' dict).
            data_dir: Path to the directory containing baseline JSON files.
                      When provided, control applicability is set from the baselines.
        """
        raw = oscal_catalog if isinstance(oscal_catalog, dict) else {}
        self._catalog = raw.get("catalog", raw)
        if data_dir:
            self._baseline_index = _build_baseline_index(data_dir)
        else:
            self._baseline_index = {}

    def _metadata(self):
        return {
            "id": "nist-800-53-rev5-guidance",
            "type": "GuidanceCatalog",
            "gemara-version": GEMARA_VERSION,
            "description": (
                "NIST Special Publication 800-53 Revision 5 — Security and Privacy Controls "
                "for Information Systems and Organizations. This catalog provides the abstract "
                "'what should be' layer: official control objectives and guidance prose."
            ),
            "author": {
                "id": "nist",
                "name": "National Institute of Standards and Technology",
                "type": "Human",
                "uri": "https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final",
            },
            "version": "Revision 5",
            "date": _now_iso(),
            "applicability-groups": [
                {
                    "id": "low",
                    "title": "Low Baseline",
                    "description": "NIST 800-53 Low Impact Baseline",
                },
                {
                    "id": "moderate",
                    "title": "Moderate Baseline",
                    "description": "NIST 800-53 Moderate Impact Baseline",
                },
                {
                    "id": "high",
                    "title": "High Baseline",
                    "description": "NIST 800-53 High Impact Baseline",
                },
            ],
        }

    def _groups(self):
        return [
            {
                "id": fam_id,
                "title": fam_title,
                "description": f"NIST 800-53 {fam_id.upper()} family: {fam_title}",
            }
            for fam_id, fam_title in NIST_FAMILIES.items()
        ]

    def build(self):
        """Return a complete GuidanceCatalog dict ready for serialization."""
        guidelines = []
        for oscal_group in self._catalog.get("groups", []):
            family_id = oscal_group.get("id", "").lower()
            if family_id not in NIST_FAMILIES:
                continue
            for ctrl in oscal_group.get("controls", []):
                param_index = _build_param_index(ctrl)
                guidelines.append(
                    _build_guideline(ctrl, family_id, param_index, self._baseline_index, BASELINES)
                )
                # Enhancements (ac-2.1, ac-2.2, …) — merge parent params
                for enh in ctrl.get("controls", []):
                    enh_params = _build_param_index(enh, parent_params=param_index)
                    guidelines.append(
                        _build_guideline(enh, family_id, enh_params, self._baseline_index, BASELINES)
                    )

        return {
            "metadata": self._metadata(),
            "title": "NIST Special Publication 800-53 Revision 5",
            "type": "Standard",
            "groups": self._groups(),
            "guidelines": guidelines,
        }
