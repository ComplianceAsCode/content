#!/bin/bash

{{% for path in FILEPATH %}}
    {{% if MISSING_FILE_PASS %}}
        rm -f {{{ path }}}
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
