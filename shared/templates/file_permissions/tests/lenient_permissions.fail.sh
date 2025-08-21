#!/bin/bash

{{%- if RECURSIVE %}}
{{%- set FIND_RECURSE_ARGS_DEP="" %}}
{{%- elif FILE_REGEX %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 1" %}}
{{%- else %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 0" %}}
{{%- endif %}}

{{%- if EXCLUDED_FILES %}}
{{% set EXCLUDED_FILES_ARGS="! -name '" + EXCLUDED_FILES|join("' ! -name '") + "'" %}}
{{%- else %}}
{{% set EXCLUDED_FILES_ARGS="" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
touch "{{{ path }}}"/cac_file_permissions_test_file
{{% if FILE_REGEX %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} {{{ EXCLUDED_FILES_ARGS }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chmod 777 {} \;
{{% elif RECURSIVE %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type d -maxdepth 1 -exec chmod 777 {} \;
{{% else %}}
chmod 777 {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chmod 777 {{{ path }}}
{{% endif %}}
{{% endfor %}}
