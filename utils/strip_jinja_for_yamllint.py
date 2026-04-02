#!/usr/bin/env python3
"""Strip Jinja2 constructs from YAML files to make them yamllint-safe.

This project uses Jinja2 templating ({{% %}}, {{{ }}}, {{# #}}) inside YAML
files.  yamllint cannot parse these constructs, so this script removes them
while preserving line numbers (replaced regions become blank lines) so that
yamllint error messages still point to the correct source lines.

Usage:
    python3 utils/strip_jinja_for_yamllint.py FILE

The cleaned content is written to stdout.
"""

import re
import sys


def _replace_with_blanks(match):
    """Replace a match with the same number of newlines to preserve line numbers."""
    return "\n" * match.group(0).count("\n")


def strip_jinja(content):
    # 1. Remove whole-line Jinja block tags: {{% ... %}} on their own line(s).
    #    Match the entire line (including leading whitespace) to avoid leaving
    #    trailing spaces behind.
    content = re.sub(
        r"^[ \t]*\{\{%.*?%\}\}[ \t]*$",
        _replace_with_blanks,
        content,
        flags=re.MULTILINE | re.DOTALL,
    )
    # Remove any remaining inline block tags (rare).
    content = re.sub(r"\{\{%.*?%\}\}", _replace_with_blanks, content, flags=re.DOTALL)

    # 2. Remove whole-line Jinja comments: {{# ... #}}
    content = re.sub(
        r"^[ \t]*\{\{#.*?#\}\}[ \t]*$",
        _replace_with_blanks,
        content,
        flags=re.MULTILINE | re.DOTALL,
    )
    # Remove any remaining inline comments.
    content = re.sub(r"\{\{#.*?#\}\}", "", content, flags=re.DOTALL)

    # 3a. Standalone Jinja expressions occupying entire lines — these typically
    #     expand to top-level YAML keys (e.g. ocil/ocil_clause macros) or
    #     Ansible tasks, so replacing them with a placeholder string would
    #     produce invalid YAML.  Replace with a YAML-safe comment placeholder
    #     to avoid trailing whitespace on otherwise blank lines.
    content = re.sub(
        r"^([ \t]*)\{\{\{.*?\}\}\}[ \t]*$",
        lambda m: m.group(1) + "# jinja" + "\n" * (m.group(0).count("\n") - 1)
        if m.group(0).count("\n") > 0
        else m.group(1) + "# jinja",
        content,
        flags=re.MULTILINE | re.DOTALL,
    )

    # 3b. Inline Jinja expressions embedded inside a YAML value — replace
    #     with a short placeholder so the surrounding YAML stays valid.
    content = re.sub(r"\{\{\{.*?\}\}\}", "JINJA_EXPRESSION", content)

    return content


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} FILE", file=sys.stderr)
        sys.exit(2)

    with open(sys.argv[1]) as f:
        sys.stdout.write(strip_jinja(f.read()))


if __name__ == "__main__":
    main()
