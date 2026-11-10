"""Framework abstraction for the Gemara exporter.

A :class:`Framework` captures everything that differs between compliance
frameworks (NIST 800-53, DISA STIG, CIS, ANSSI, …) so the *same* conversion
code in :mod:`gemara.catalog`, :mod:`gemara.policy` and :mod:`gemara.mapping`
can turn **any** ComplianceAsCode control file into Gemara artifacts.

Design goals:

* The NIST path is the reference implementation.  :class:`NistFramework`
  reproduces byte-for-byte the ids / titles / descriptions the builders emitted
  before this abstraction existed, so existing output and tests are unchanged
  (the builders default to ``NistFramework`` when no framework is passed).
* Any single-file / split-dir control file (``reference_type`` of ``stigid``,
  ``cis``, ``anssi``, …) works through :class:`GenericFramework` with no new
  code — only naming/wording differs, and that is data on the instance.

What stays framework-independent (and therefore lives in the builders, not
here): the control→rule → ``assessment-requirement`` conversion, variable
(``var=value``) → ``parameters`` resolution, baseline filtering, and the
short-CaC-rule-name ``requirement-id`` contract with the OpenSCAP provider.
"""

from typing import Dict, List, Optional

# ---------------------------------------------------------------------------
# Shared constants
# ---------------------------------------------------------------------------

COMPLIANCEASCODE_AUTHOR: Dict[str, str] = {
    "id": "complianceascode",
    "name": "ComplianceAsCode Project",
    "type": "Software",
    "uri": "https://github.com/ComplianceAsCode/content",
}

# NIST 800-53 Rev 5 control families (control-id prefix -> family title).
NIST_FAMILIES: Dict[str, str] = {
    "ac": "Access Control",
    "at": "Awareness and Training",
    "au": "Audit and Accountability",
    "ca": "Assessment, Authorization, and Monitoring",
    "cm": "Configuration Management",
    "cp": "Contingency Planning",
    "ia": "Identification and Authentication",
    "ir": "Incident Response",
    "ma": "Maintenance",
    "mp": "Media Protection",
    "pe": "Physical and Environmental Protection",
    "pl": "Planning",
    "pm": "Program Management",
    "ps": "Personnel Security",
    "pt": "PII Processing and Transparency",
    "ra": "Risk Assessment",
    "sa": "System and Services Acquisition",
    "sc": "System and Communications Protection",
    "si": "System and Information Integrity",
    "sr": "Supply Chain Risk Management",
}


# ---------------------------------------------------------------------------
# Base framework (generic single-group behaviour)
# ---------------------------------------------------------------------------

class Framework:
    """Generic framework driver.

    Suitable for any CaC control file whose controls do not belong to a
    well-known family taxonomy: every control is placed in a single catalog
    group.  Subclass and override the grouping / wording hooks for frameworks
    that need a richer structure (see :class:`NistFramework`).
    """

    def __init__(
        self,
        key: str,
        reference_type: str,
        short_name: str,
        long_name: str,
        version_label: str = "",
        author: Optional[Dict[str, str]] = None,
        guidance_key: Optional[str] = None,
    ) -> None:
        #: artifact-id slug, e.g. ``nist-800-53-rev5``, ``stig``, ``cis``
        self.key = key
        #: CaC control-file ``reference_type`` (``nist``, ``stigid``, ``cis``…)
        self.reference_type = reference_type
        #: short human name used in titles, e.g. ``DISA STIG``
        self.short_name = short_name
        #: descriptive name used in prose, e.g. ``DISA Security Technical …``
        self.long_name = long_name
        #: version label carried into metadata/mapping-references (may be "")
        self.version_label = version_label
        self.author = dict(author) if author else dict(COMPLIANCEASCODE_AUTHOR)
        #: shared GuidanceCatalog id, or None when the framework has no
        #: external guidance source (a synthetic one is derived instead).
        self.guidance_key = guidance_key

    # -- id helpers ---------------------------------------------------------

    def catalog_id(self, product: str) -> str:
        return f"{self.key}-{product}"

    def catalog_group_id(self, product: str, group: str) -> str:
        return f"{self.key}-{product}-{group}"

    def policy_id(self, product: str) -> str:
        return f"{self.key}-{product}-policy"

    def guidance_id(self) -> str:
        return self.guidance_key or f"{self.key}-guidance"

    # -- grouping (single default group) -----------------------------------

    def _default_group_id(self) -> str:
        return "controls"

    def groups(self) -> List[Dict[str, str]]:
        """The ``groups`` block for the catalog/guidance."""
        gid = self._default_group_id()
        return [self.group_meta(gid)]

    def group_for(self, control_id: str) -> str:
        """Map a control id to the id of the group it belongs to."""
        return self._default_group_id()

    def group_meta(self, group_id: str) -> Dict[str, str]:
        return {
            "id": group_id,
            "title": self.short_name,
            "description": f"{self.short_name} controls",
        }

    # -- descriptions / titles ---------------------------------------------

    def catalog_description(self, product: str) -> str:
        return (
            f"{self.long_name} controls for {product.upper()}, "
            "generated from ComplianceAsCode"
        )

    def catalog_group_description(self, product: str, group_id: str) -> str:
        title = self.group_meta(group_id)["title"]
        return (
            f"{self.long_name} controls for {product.upper()}, "
            f"generated from ComplianceAsCode ({title})"
        )

    def baseline_group(
        self, product: str, level_id: str, inherits: List[str]
    ) -> Dict[str, str]:
        desc = f"{self.short_name} {level_id.capitalize()} level for {product.upper()}"
        if inherits:
            parents = ", ".join(p.capitalize() for p in inherits)
            desc += f" (inherits {parents})"
        return {
            "id": f"{product}-{level_id}",
            "title": f"{product.upper()} {level_id.capitalize()} Baseline",
            "description": desc,
        }

    # -- policy strings -----------------------------------------------------

    def policy_title(self, full_name: str) -> str:
        return f"{self.short_name} for {full_name}"

    def policy_description(self, full_name: str) -> str:
        return (
            f"Automated evaluation policy for {self.short_name} on {full_name}, "
            "using ComplianceAsCode rules. requirement-id values are short CaC "
            "rule names (the OpenSCAP provider adds the "
            "xccdf_org.ssgproject.content_rule_ prefix)."
        )

    def catalog_ref_title(self, product: str) -> str:
        return f"{self.short_name} Control Catalog for {product.upper()}"

    def guidance_ref_title(self) -> str:
        return f"{self.short_name} Guidance Catalog"

    # -- mapping strings ----------------------------------------------------

    def mapping_description(self, product: str) -> str:
        return (
            f"Mapping from {self.short_name} controls to ComplianceAsCode "
            f"rules for {product.upper()}"
        )

    def mapping_title(self, product: str) -> str:
        return f"ComplianceAsCode Rules to {self.short_name} for {product.upper()}"

    def mapping_catalog_ref_title(self, product: str) -> str:
        return (
            f"ComplianceAsCode {self.short_name} Control Catalog for "
            f"{product.upper()}"
        )

    def mapping_catalog_ref_id(self) -> str:
        return f"cac-{self.key}-control-catalog"


# ---------------------------------------------------------------------------
# NIST 800-53 framework (families + baseline wording)
# ---------------------------------------------------------------------------

class NistFramework(Framework):
    """NIST SP 800-53 Rev 5 — the reference framework.

    Reproduces exactly the ids/titles/descriptions the builders emitted before
    the framework abstraction was introduced.
    """

    def __init__(self) -> None:
        super().__init__(
            key="nist-800-53-rev5",
            reference_type="nist",
            short_name="NIST SP 800-53 Rev 5",
            long_name="NIST Special Publication 800-53 Revision 5",
            version_label="Revision 5",
            author=dict(COMPLIANCEASCODE_AUTHOR),
            guidance_key="nist-800-53-rev5-guidance",
        )

    def groups(self) -> List[Dict[str, str]]:
        return [self.group_meta(fam_id) for fam_id in NIST_FAMILIES]

    def group_for(self, control_id: str) -> str:
        fam = control_id.split("-")[0].lower()
        if fam not in NIST_FAMILIES:
            fam = next(iter(NIST_FAMILIES))  # fallback to first family
        return fam

    def group_meta(self, group_id: str) -> Dict[str, str]:
        title = NIST_FAMILIES.get(group_id, group_id)
        return {
            "id": group_id,
            "title": title,
            "description": f"NIST 800-53 {group_id.upper()} family: {title}",
        }

    def catalog_description(self, product: str) -> str:
        return (
            f"NIST Special Publication 800-53 Revision 5 controls for "
            f"{product.upper()}, generated from ComplianceAsCode"
        )

    def catalog_group_description(self, product: str, group_id: str) -> str:
        return (
            f"NIST Special Publication 800-53 Revision 5 controls for "
            f"{product.upper()}, generated from ComplianceAsCode "
            f"({group_id.upper()} family)"
        )

    def baseline_group(
        self, product: str, level_id: str, inherits: List[str]
    ) -> Dict[str, str]:
        desc = (
            f"NIST 800-53 {level_id.capitalize()} impact baseline for "
            f"{product.upper()}"
        )
        if inherits:
            parents = ", ".join(p.capitalize() for p in inherits)
            desc += f" (inherits {parents})"
        return {
            "id": f"{product}-{level_id}",
            "title": f"{product.upper()} {level_id.capitalize()} Baseline",
            "description": desc,
        }

    def mapping_description(self, product: str) -> str:
        return (
            f"Mapping from NIST 800-53 Rev 5 controls to ComplianceAsCode "
            f"rules for {product.upper()}"
        )

    def mapping_title(self, product: str) -> str:
        return f"ComplianceAsCode Rules to NIST 800-53 for {product.upper()}"

    def mapping_catalog_ref_title(self, product: str) -> str:
        return (
            f"ComplianceAsCode NIST 800-53 Rev 5 Control Catalog for "
            f"{product.upper()}"
        )

    def mapping_catalog_ref_id(self) -> str:
        # Preserved verbatim from the pre-framework implementation.
        return "cac-nist-800-53-control-catalog"


# ---------------------------------------------------------------------------
# Registry of known non-NIST frameworks
# ---------------------------------------------------------------------------

def _generic(**kw: str) -> "Framework":
    return Framework(**kw)  # type: ignore[arg-type]


#: Pre-wired frameworks keyed by a short CLI name.  NIST is handled specially
#: (families), everything else is a :class:`GenericFramework` instance.
_KNOWN: Dict[str, "Framework"] = {
    "nist": NistFramework(),
    "stig": Framework(
        key="stig",
        reference_type="stigid",
        short_name="DISA STIG",
        long_name="DISA Security Technical Implementation Guide",
        version_label="",
        guidance_key=None,
    ),
    "cis": Framework(
        key="cis",
        reference_type="cis",
        short_name="CIS Benchmark",
        long_name="CIS Benchmark",
        version_label="",
        guidance_key=None,
    ),
    "anssi": Framework(
        key="anssi",
        reference_type="anssi",
        short_name="ANSSI-BP-028",
        long_name="ANSSI-BP-028 Recommendations",
        version_label="",
        guidance_key=None,
    ),
}


def get_framework(name: str) -> "Framework":
    """Return a pre-wired framework by CLI name (``nist``, ``stig``, ``cis``…).

    Raises KeyError with the list of known names when unknown.
    """
    try:
        return _KNOWN[name]
    except KeyError:
        raise KeyError(
            f"unknown framework {name!r}; known: {', '.join(sorted(_KNOWN))}"
        )


def known_frameworks() -> List[str]:
    return sorted(_KNOWN)


def framework_for_control_file(
    stem: str,
    product: str,
    reference_type: str = "",
    title: str = "",
) -> "Framework":
    """Return a Framework for an arbitrary CaC control-file stem.

    Profiles name their backing control file in the resolved profile's
    ``policies`` field (e.g. ``stig_rhel9``, ``ospp``, ``pcidss_4``,
    ``nist_800_171``).  Well-known stems map to the pre-wired frameworks;
    anything else is synthesized as a generic single-group framework keyed on
    the stem, so every control-file-backed profile gets a catalog keyed on that
    file's own control ids.

    Args:
        stem: control-file stem (without .yml), e.g. ``ospp`` or ``cis_rhel9``.
        product: product id, used to strip a trailing ``_<product>`` from the key.
        reference_type: the control file's ``reference_type`` (for synthesized).
        title: the control file's title (for synthesized short/long name).
    """
    if stem == "nist_800_53":
        return get_framework("nist")
    if stem.startswith("stig"):
        return get_framework("stig")
    if stem == "cis" or stem.startswith("cis_"):
        return get_framework("cis")
    if stem == "anssi" or stem.startswith("anssi"):
        return get_framework("anssi")

    key = stem
    if key.endswith(f"_{product}"):
        key = key[: -len(product) - 1]
    short = title or key.replace("_", " ").upper()
    return Framework(
        key=key,
        reference_type=reference_type or key,
        short_name=short,
        long_name=title or short,
        version_label="",
        guidance_key=None,
    )
