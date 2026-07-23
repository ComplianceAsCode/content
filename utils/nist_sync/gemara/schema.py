"""Gemara schema constants and structural validation."""

GEMARA_VERSION = "1.2.0"

# #Lifecycle: "Active" | "Draft" | "Deprecated" | "Retired"  (default: "Active")
VALID_STATES = {"Active", "Draft", "Deprecated", "Retired"}

# #RelationshipType enum from mappingdocument.cue
VALID_RELATIONSHIPS = {
    "implements",
    "implemented-by",
    "supports",
    "supported-by",
    "equivalent",
    "subsumes",
    "no-match",
    "relates-to",
}

# #ConfidenceLevel from collections.cue
VALID_CONFIDENCE_LEVELS = {"Undetermined", "Low", "Medium", "High"}
VALID_ARTIFACT_TYPES = {
    "CapabilityCatalog",
    "ControlCatalog",
    "GuidanceCatalog",
    "ThreatCatalog",
    "RiskCatalog",
    "Policy",
    "MappingDocument",
    "Lexicon",
    "EvaluationLog",
    "EnforcementLog",
    "VectorCatalog",
    "PrincipleCatalog",
    "AuditLog",
}


VALID_EVALUATION_MODES = {"Automated", "Semi-Automated", "Manual"}


def _err(errors, msg):
    errors.append(msg)


def validate_catalog(catalog):
    """
    Validate a ControlCatalog dict against Gemara structural rules.
    Returns a list of error strings (empty list means valid).
    """
    errors = []

    if not isinstance(catalog, dict):
        return ["catalog must be a dict"]

    # Required top-level fields
    for field in ("metadata", "title", "groups"):
        if field not in catalog:
            _err(errors, f"missing required field: {field!r}")

    metadata = catalog.get("metadata", {})
    if not isinstance(metadata, dict):
        _err(errors, "metadata must be a dict")
    else:
        if metadata.get("type") != "ControlCatalog":
            _err(errors, f"metadata.type must be 'ControlCatalog', got {metadata.get('type')!r}")
        for field in ("id", "gemara-version", "description", "author"):
            if field not in metadata:
                _err(errors, f"missing required metadata field: {field!r}")

    # Collect defined group IDs
    groups = catalog.get("groups", [])
    group_ids = {g["id"] for g in groups if isinstance(g, dict) and "id" in g}

    # Collect defined applicability-group IDs
    app_groups = metadata.get("applicability-groups", []) if isinstance(metadata, dict) else []
    app_group_ids = {g["id"] for g in app_groups if isinstance(g, dict) and "id" in g}

    controls = catalog.get("controls", [])
    if not isinstance(controls, list):
        _err(errors, "controls must be a list")
    else:
        seen_ids = set()
        for i, ctrl in enumerate(controls):
            if not isinstance(ctrl, dict):
                _err(errors, f"controls[{i}] must be a dict")
                continue
            for field in ("id", "title", "objective", "group", "state"):
                if field not in ctrl:
                    _err(errors, f"controls[{i}] missing required field: {field!r}")
            ctrl_id = ctrl.get("id", f"<index {i}>")
            if ctrl_id in seen_ids:
                _err(errors, f"duplicate control id: {ctrl_id!r}")
            seen_ids.add(ctrl_id)
            if ctrl.get("state") not in VALID_STATES:
                _err(errors, f"control {ctrl_id!r}: invalid state {ctrl.get('state')!r}")
            if ctrl.get("group") and ctrl["group"] not in group_ids:
                _err(errors, f"control {ctrl_id!r}: group {ctrl['group']!r} not in groups")
            for req in ctrl.get("assessment-requirements", []):
                for ref in req.get("applicability", []):
                    if ref not in app_group_ids:
                        _err(errors, f"control {ctrl_id!r}: applicability {ref!r} not in applicability-groups")

    return errors


def validate_mapping(mapping):
    """
    Validate a MappingDocument dict against Gemara structural rules.
    Returns a list of error strings (empty list means valid).
    """
    errors = []

    if not isinstance(mapping, dict):
        return ["mapping must be a dict"]

    for field in ("metadata", "title", "source-reference", "target-reference", "mappings"):
        if field not in mapping:
            _err(errors, f"missing required field: {field!r}")

    metadata = mapping.get("metadata", {})
    if isinstance(metadata, dict):
        if metadata.get("type") != "MappingDocument":
            _err(errors, f"metadata.type must be 'MappingDocument', got {metadata.get('type')!r}")

    mappings = mapping.get("mappings", [])
    if not isinstance(mappings, list):
        _err(errors, "mappings must be a list")
    else:
        seen_ids = set()
        for i, m in enumerate(mappings):
            if not isinstance(m, dict):
                _err(errors, f"mappings[{i}] must be a dict")
                continue
            mid = m.get("id", f"<index {i}>")
            if mid in seen_ids:
                _err(errors, f"duplicate mapping id: {mid!r}")
            seen_ids.add(mid)
            rel = m.get("relationship")
            if rel not in VALID_RELATIONSHIPS:
                _err(errors, f"mapping {mid!r}: invalid relationship {rel!r}")
            if rel != "no-match" and not m.get("targets"):
                _err(errors, f"mapping {mid!r}: non-no-match relationship requires targets")

    return errors


def validate_policy(policy):
    """
    Validate a Policy dict against Gemara structural rules.
    Returns a list of error strings (empty list means valid).
    """
    errors = []

    if not isinstance(policy, dict):
        return ["policy must be a dict"]

    for field in ("metadata", "title", "contacts", "scope", "imports", "adherence"):
        if field not in policy:
            _err(errors, f"missing required field: {field!r}")

    metadata = policy.get("metadata", {})
    if not isinstance(metadata, dict):
        _err(errors, "metadata must be a dict")
    else:
        if metadata.get("type") != "Policy":
            _err(errors, f"metadata.type must be 'Policy', got {metadata.get('type')!r}")
        for field in ("id", "gemara-version", "description", "author", "mapping-references"):
            if field not in metadata:
                _err(errors, f"missing required metadata field: {field!r}")

        mapping_ref_ids = set()
        for ref in metadata.get("mapping-references", []):
            if not isinstance(ref, dict):
                _err(errors, "mapping-references entries must be dicts")
                continue
            for rf in ("id", "title", "version"):
                if rf not in ref:
                    _err(errors, f"mapping-reference missing field: {rf!r}")
            if "id" in ref:
                mapping_ref_ids.add(ref["id"])

    imports = policy.get("imports", {})
    if isinstance(imports, dict):
        for cat_ref in imports.get("catalogs", []):
            ref_id = cat_ref.get("reference-id", "")
            if mapping_ref_ids and ref_id not in mapping_ref_ids:
                _err(errors, f"imports.catalogs reference-id {ref_id!r} not in mapping-references")

    adherence = policy.get("adherence", {})
    if isinstance(adherence, dict):
        plans = adherence.get("assessment-plans", [])
        if not isinstance(plans, list) or len(plans) == 0:
            _err(errors, "adherence.assessment-plans must be a non-empty list")
        else:
            seen_ids = set()
            for i, plan in enumerate(plans):
                if not isinstance(plan, dict):
                    _err(errors, f"assessment-plans[{i}] must be a dict")
                    continue
                for field in ("id", "requirement-id"):
                    if field not in plan:
                        _err(errors, f"assessment-plans[{i}] missing required field: {field!r}")
                pid = plan.get("id", f"<index {i}>")
                if pid in seen_ids:
                    _err(errors, f"duplicate assessment-plan id: {pid!r}")
                seen_ids.add(pid)

    return errors


def validate_guidance(guidance):
    """
    Validate a GuidanceCatalog dict against Gemara structural rules.
    Returns a list of error strings (empty list means valid).
    """
    errors = []

    if not isinstance(guidance, dict):
        return ["guidance must be a dict"]

    for field in ("metadata", "title", "type", "groups", "guidelines"):
        if field not in guidance:
            _err(errors, f"missing required field: {field!r}")

    metadata = guidance.get("metadata", {})
    if not isinstance(metadata, dict):
        _err(errors, "metadata must be a dict")
    else:
        if metadata.get("type") != "GuidanceCatalog":
            _err(errors, f"metadata.type must be 'GuidanceCatalog', got {metadata.get('type')!r}")
        for field in ("id", "gemara-version", "description", "author"):
            if field not in metadata:
                _err(errors, f"missing required metadata field: {field!r}")

    valid_guidance_types = {"Standard", "Regulation", "Best Practice", "Framework"}
    if guidance.get("type") not in valid_guidance_types:
        _err(errors, f"type must be one of {sorted(valid_guidance_types)}, got {guidance.get('type')!r}")

    groups = guidance.get("groups", [])
    group_ids = {g["id"] for g in groups if isinstance(g, dict) and "id" in g}

    app_groups = metadata.get("applicability-groups", []) if isinstance(metadata, dict) else []
    app_group_ids = {g["id"] for g in app_groups if isinstance(g, dict) and "id" in g}

    guidelines = guidance.get("guidelines", [])
    if not isinstance(guidelines, list):
        _err(errors, "guidelines must be a list")
    else:
        seen_ids = set()
        for i, g in enumerate(guidelines):
            if not isinstance(g, dict):
                _err(errors, f"guidelines[{i}] must be a dict")
                continue
            for field in ("id", "title", "objective", "group", "state"):
                if field not in g:
                    _err(errors, f"guidelines[{i}] missing required field: {field!r}")
            gid = g.get("id", f"<index {i}>")
            if gid in seen_ids:
                _err(errors, f"duplicate guideline id: {gid!r}")
            seen_ids.add(gid)
            if g.get("state") not in VALID_STATES:
                _err(errors, f"guideline {gid!r}: invalid state {g.get('state')!r}")
            if g.get("group") and g["group"] not in group_ids:
                _err(errors, f"guideline {gid!r}: group {g['group']!r} not in groups")
            for ref in g.get("applicability", []):
                if app_group_ids and ref not in app_group_ids:
                    _err(errors, f"guideline {gid!r}: applicability {ref!r} not in applicability-groups")

    return errors
