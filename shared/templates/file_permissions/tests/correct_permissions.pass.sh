#!/bin/bash

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
touch "{{{ path }}}"/cac_file_permissions_test_file
{{% if FILE_REGEX %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chmod {{{ FILEMODE }}} {} \;
{{% elif RECURSIVE %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type d -exec chmod {{{ FILEMODE }}} {} \;
{{% else %}}
chmod {{{ FILEMODE }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chmod {{{ FILEMODE }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
