#!/bin/bash
{{% if PACKAGES %}}
# packages = {{{PACKAGES}}}
{{% endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ -d {{{ path }}} ]; then
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec rm -f {} \;
{{% else %}}
rm -f {{{ path }}}
{{% endif %}}
fi
{{% else %}}
if [ -f {{{ path }}} ]; then
rm -f {{{ path }}}
fi
{{% endif %}}
{{% endfor %}}

