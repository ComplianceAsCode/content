#!/bin/bash

useradd testuser_123
{{%- for own in OWNERS %}}
id "{{{ own }}}" &>/dev/null || useradd {{{ own }}}
{{%- endfor %}}

{{%- if RECURSIVE %}}
{{% set FIND_RECURSE_ARGS="" %}}
{{%- else %}}
{{% set FIND_RECURSE_ARGS="-maxdepth 1" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex owner"
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chown testuser_123 {} \;
{{% else %}}
chown testuser_123 {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
if [ -L {{{ path }}} ]; then
    rm {{{ path }}}
    touch {{{ path }}}
fi
chown testuser_123 {{{ path }}}
{{% endif %}}
{{% endfor %}}
