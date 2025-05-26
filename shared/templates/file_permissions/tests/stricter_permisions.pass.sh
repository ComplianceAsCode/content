#!/bin/bash

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
touch "{{{ path }}}"/cac_file_permissions_test_file
{{% if FILE_REGEX %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chmod {{{ FILEMODE }}} {} \;
{{% elif RECURSIVE %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} -type d -exec chmod {{{ FILEMODE }}} {} \;
{{% else %}}
{{% if ALLOW_STRICTER_PERMISSIONS %}}
chmod 000 {{{ path }}}
{{% else %}}
chmod {{{ FILEMODE }}} {{{ path }}}
{{% endif %}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
{{% if ALLOW_STRICTER_PERMISSIONS %}}
chmod 000 {{{ path }}}
{{% else %}}
chmod {{{ FILEMODE }}}  {{{ path }}}
{{% endif %}}
{{% endif %}}
{{% endfor %}}
