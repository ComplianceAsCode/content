#!/bin/bash

{{%- if RECURSIVE %}}
{{% set FIND_RECURSE_ARGS="" %}}
{{%- else %}}
{{% set FIND_RECURSE_ARGS="-maxdepth 1" %}}
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
{{% if FILE_REGEX %}}
find -H {{{ path }}} {{{ FIND_RECURSE_ARGS }}} {{{ EXCLUDED_FILES_ARGS }}} -type f -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chmod 777 {} \;
{{% elif RECURSIVE %}}
find -H {{{ path }}} -type d -maxdepth 1 -exec chmod 777 {} \;
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
