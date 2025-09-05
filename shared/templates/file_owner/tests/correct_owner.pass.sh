#!/bin/bash

{{% set OWNERS=UID_OR_NAME.split("|") %}}
{{%- for own in OWNERS %}}
id "{{{ own }}}" &>/dev/null || useradd {{{ own }}}
{{%- endfor %}}

{{% if OWNERS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple owners"
exit 1;
{{% else %}}

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
touch "{{{ path }}}"/cac_file_owner_test_file
{{% if FILE_REGEX %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chown {{{ UID_OR_NAME }}} {} \;
{{% elif RECURSIVE %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} -type d -exec chown {{{ UID_OR_NAME }}} {} \;
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
