"""YAML serialization settings shared by Gemara artifact generators."""

from ruamel.yaml import YAML


def configure_yaml(yaml: YAML) -> YAML:
    """Configure a ruamel YAML instance for lint-clean Gemara output."""
    yaml.default_flow_style = False
    yaml.allow_unicode = True
    # Keep long Gemara objectives/descriptions on one line.  ruamel emits
    # trailing spaces when it wraps plain scalars at a smaller width, which
    # violates yamllint's trailing-spaces rule.
    yaml.width = 4096
    # The shared ComplyTime MegaLinter configuration extends yamllint's default
    # indentation rules.  In particular, sequence items must be indented beneath
    # their mapping key (``key:\n  - value``), rather than emitted at the key's
    # indentation level (``key:\n- value``).
    yaml.indent(mapping=2, sequence=4, offset=2)
    # ruamel aliases list/dict objects by id(); CPython can reuse the same id
    # for distinct short-lived values, producing spurious YAML anchors/aliases.
    yaml.representer.ignore_aliases = lambda data: True
    return yaml
