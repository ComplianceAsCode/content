#!/bin/bash

{{% set OWNERS=UID_OR_NAME.split("|") %}}
{{%- for own in OWNERS %}}
id "{{{ own }}}" &>/dev/null || useradd {{{ own }}}
{{%- endfor %}}

{{% if OWNERS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple owners"
exit 1;
{{% else %}}
{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex owner"
exit 1;
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chown {{{ UID_OR_NAME }}} {} \;
{{% else %}}
chown {{{ UID_OR_NAME }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chown {{{ UID_OR_NAME }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
{{% endif %}}
