#!/bin/bash

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chmod {{{ FILEMODE }}} {} \;
{{% else %}}
{{% if ALLOW_STRICTER_PERMISSIONS %}}
chmod 000 {{{ path }}}
{{% else %}}
chmod {{{ FILEMODE }}}  {{{ path }}}
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
