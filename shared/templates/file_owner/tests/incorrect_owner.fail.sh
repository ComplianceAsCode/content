#!/bin/bash
{{%- if NO_REMEDIATION %}}
# remediation = none
{{%- endif %}}
useradd testuser_123
{{%- for own in OWNERS %}}
id "{{{ own }}}" &>/dev/null || useradd {{{ own }}}
{{%- endfor %}}

{{%- if RECURSIVE %}}
{{%- set FIND_RECURSE_ARGS_DEP="" %}}
{{%- set FIND_RECURSE_ARGS_SYM="" %}}
{{%- else %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 1" %}}
{{%- set FIND_RECURSE_ARGS_SYM="-L" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chown testuser_123 {} \;
{{% elif RECURSIVE %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} -type d -exec chown testuser_123 {} \;
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
