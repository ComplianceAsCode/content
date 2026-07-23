"""Builds a Gemara MappingDocument linking CaC controls to rule IDs."""

import re
from datetime import datetime, timezone

from .schema import GEMARA_VERSION
from .status_map import (
    has_mapping,
    map_confidence,
    map_relationship,
    map_strength,
)

_VAR_ASSIGN_RE = re.compile(r'^[a-z][a-z0-9_]*=[^\s]+$')

_CATALOG_REF_ID = "cac-nist-800-53-control-catalog"
_RULES_REF_ID = "cac-rules"


def _is_variable_assignment(rule_entry):
    return bool(_VAR_ASSIGN_RE.match(rule_entry))


def _now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


class GemaraMappingBuilder:
    """Builds a Gemara MappingDocument from CaC policy controls."""

    def __init__(self, product, catalog_id, policy):
        self.product = product
        self.catalog_id = catalog_id
        self.policy = policy

    def _metadata(self):
        mapping_id = f"{self.catalog_id}-rules-mapping"
        return {
            "id": mapping_id,
            "type": "MappingDocument",
            "gemara-version": GEMARA_VERSION,
            "description": (
                f"Mapping from NIST 800-53 Rev 5 controls to ComplianceAsCode "
                f"rules for {self.product.upper()}"
            ),
            "author": {
                "id": "complianceascode",
                "name": "ComplianceAsCode Project",
                "type": "Software",
                "uri": "https://github.com/ComplianceAsCode/content",
            },
            "date": _now_iso(),
            # #MappingReference requires id, title, version (version is required)
            "mapping-references": [
                {
                    "id": _CATALOG_REF_ID,
                    "title": f"ComplianceAsCode NIST 800-53 Rev 5 Control Catalog for {self.product.upper()}",
                    "version": "Revision 5",
                    "url": "https://github.com/ComplianceAsCode/content",
                },
                {
                    "id": _RULES_REF_ID,
                    "title": f"ComplianceAsCode {self.product.upper()} Rules",
                    "version": "1.0.0",
                    "url": "https://github.com/ComplianceAsCode/content",
                },
            ],
        }

    def _build_mapping_entry(self, control, rule_id):
        cac_status = control.status if control.status else "pending"
        relationship = map_relationship(cac_status) or "implements"
        strength = map_strength(cac_status) or 5
        confidence = map_confidence(cac_status) or "Medium"

        rationale = (
            control.notes.strip()
            if getattr(control, "notes", None)
            else "Automated enforcement via ComplianceAsCode rule"
        )

        return {
            "id": f"{control.id}--{rule_id}",
            "source": control.id,
            "relationship": relationship,
            "targets": [
                {
                    "entry-id": rule_id,
                    "strength": strength,
                    # #ConfidenceLevel: "Undetermined" | "Low" | "Medium" | "High"
                    "confidence-level": confidence,
                    "rationale": rationale,
                }
            ],
        }

    def build(self):
        """Return a complete MappingDocument dict ready for serialization."""
        mappings = []
        seen_ids = set()

        for control in self.policy.controls:
            cac_status = control.status if control.status else "pending"
            if not has_mapping(cac_status):
                continue

            for rule_entry in (control.rules or []):
                if _is_variable_assignment(rule_entry):
                    continue

                mapping_id = f"{control.id}--{rule_entry}"
                if mapping_id in seen_ids:
                    continue
                seen_ids.add(mapping_id)

                mappings.append(self._build_mapping_entry(control, rule_entry))

        return {
            "metadata": self._metadata(),
            "title": f"ComplianceAsCode Rules to NIST 800-53 for {self.product.upper()}",
            # source-reference uses reference-id pointing to a mapping-reference
            "source-reference": {
                "reference-id": _CATALOG_REF_ID,
                # #EntryType: Guideline|Statement|Control|AssessmentRequirement|...
                "entry-type": "Control",
            },
            "target-reference": {
                "reference-id": _RULES_REF_ID,
                "entry-type": "AssessmentRequirement",
            },
            "mappings": mappings,
        }
