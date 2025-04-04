#!/bin/bash

useradd testuser_123

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
touch "{{{ path }}}"/cac_file_owner_test_file
{{% if FILE_REGEX %}}
find -L {{{ path }}} {{{ FIND_RECURSE_ARGS }}} -type f -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chown testuser_123 {} \;
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
