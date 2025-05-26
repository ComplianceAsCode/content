#!/bin/bash

{{% for path in FILEPATH %}}
if [ -d {{{ path }}} ]; then
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec rm -f {} \;
{{% else %}}
rm -rf {{{ path }}}
{{% endif %}}
else
rm -f {{{ path }}}
fi
{{% endfor %}}
