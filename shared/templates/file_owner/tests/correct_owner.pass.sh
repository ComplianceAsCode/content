#!/bin/bash
{{% if PACKAGES %}}
# packages = {{{PACKAGES}}}
{{% endif %}}

{{% set OWNERS=UID_OR_NAME.split("|") %}}
{{% if OWNERS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple owners"
exit 1;
{{% else %}}
{{% for own in OWNERS %}}
{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex owner"
exit 1;
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chown {{{ own }}} {} \;
{{% else %}}
chown {{{ own }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chown {{{ own }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
{{% endfor %}}
{{% endif %}}
