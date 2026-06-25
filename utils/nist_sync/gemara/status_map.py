"""Maps ComplianceAsCode control status values to Gemara fields."""

# CaC status -> Gemara #Lifecycle state (capitalized as per CUE schema)
# Gemara state reflects control *definition* maturity, not automation level.
# Automation level is captured in MappingDocument strength/confidence fields.
CAC_TO_GEMARA_STATE = {
    "automated": "Active",
    "supported": "Active",
    "partial": "Active",
    "manual": "Active",
    "inherently met": "Active",
    "documentation": "Active",
    "planned": "Draft",
    "pending": "Draft",
    "does not meet": "Deprecated",
    "not applicable": "Retired",
}

# CaC status -> Gemara #RelationshipType
# Valid values: implements, implemented-by, supports, supported-by,
#               equivalent, subsumes, no-match, relates-to
CAC_TO_RELATIONSHIP = {
    "automated": "implements",
    "supported": "implements",
    "partial": "supports",       # "partially-implements" is not in the schema
    "manual": "implements",
    "inherently met": "equivalent",
    "documentation": "implements",
}

# CaC status -> mapping strength (1-10, measures automation completeness)
CAC_TO_STRENGTH = {
    "automated": 8,
    "supported": 7,
    "partial": 5,
    "manual": 6,
    "inherently met": 9,
    "documentation": 4,
}

# CaC status -> Gemara #ConfidenceLevel (capitalized as per CUE schema)
# Valid values: "Undetermined" | "Low" | "Medium" | "High"
CAC_TO_CONFIDENCE = {
    "automated": "High",
    "supported": "High",
    "partial": "Medium",
    "manual": "Medium",
    "inherently met": "High",
    "documentation": "Medium",
}

# Statuses that produce no mapping entry (control not implemented)
NO_MAPPING_STATUSES = {"planned", "pending", "does not meet", "not applicable"}


def map_state(cac_status):
    """Return the Gemara state for a CaC status string."""
    return CAC_TO_GEMARA_STATE.get(cac_status, "Draft")


def map_relationship(cac_status):
    """Return the Gemara relationship type for a CaC status, or None if not mappable."""
    return CAC_TO_RELATIONSHIP.get(cac_status)


def map_strength(cac_status):
    """Return the Gemara mapping strength (1-10) for a CaC status, or None if not mappable."""
    return CAC_TO_STRENGTH.get(cac_status)


def map_confidence(cac_status):
    """Return the Gemara confidence level string for a CaC status, or None if not mappable."""
    return CAC_TO_CONFIDENCE.get(cac_status)


def has_mapping(cac_status):
    """Return True if the status produces mapping entries in the MappingDocument."""
    return cac_status not in NO_MAPPING_STATUSES
