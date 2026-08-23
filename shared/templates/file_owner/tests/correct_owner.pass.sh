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
{{%- elif FILE_REGEX %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 1" %}}
{{%- else %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 0" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
touch "{{{ path }}}"/cac_file_owner_test_file
{{% if FILE_REGEX %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chown {{{ UID_OR_NAME }}} {} \;
{{% elif RECURSIVE %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type d -exec chown {{{ UID_OR_NAME }}} {} \;
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
