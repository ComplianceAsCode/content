#!/bin/bash

{{% for path in FILEPATH %}}
    {{% if MISSING_FILE_PASS %}}
{{% if path.endswith("/") %}}
{{% if FILE_REGEX %}}
        echo "Create specific tests for this rule because of regex"
{{% else %}}
rm -rf {{{ path }}}
{{% endif %}}
{{% else %}}
        rm -f {{{ path }}}
    {{% endif %}}
{{% else %}}
        {{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if RECURSIVE %}}
        find -L {{{ path }}} -type d -exec chown {{{ FILEUID }}} {} \;
{{% else %}}
        chown {{{ FILEUID }}} {{{ path }}}
{{%endif %}}
        {{% else %}}
        if [ ! -f {{{ path }}} ]; then
            mkdir -p "$(dirname '{{{ path }}}')"
            touch {{{ path }}}
        fi
        chown {{{ FILEUID }}} {{{ path }}}
        {{% endif %}}
    {{% endif %}}
{{% endfor %}}
