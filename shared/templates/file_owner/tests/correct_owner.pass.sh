#!/bin/bash

{{% for path in FILEPATH %}}
{{% if IS_DIRECTORY and FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif IS_DIRECTORY and RECURSIVE %}}
find -L {{{ path }}} -type d -exec chown {{{ FILEUID }}} {} \;
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chown {{{ FILEUID }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
