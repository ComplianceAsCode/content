#!/bin/bash

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chown {{{ FILEUID }}} {} \;
{{% else %}}
chown {{{ FILEUID }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chown {{{ FILEUID }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
