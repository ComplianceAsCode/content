#!/bin/bash

{{% for path in FILEPATH %}}
    {{% if MISSING_FILE_PASS %}}
        rm -f {{{ path }}}
    {{% else %}}
        {{% if IS_DIRECTORY and RECURSIVE %}}
        find -L {{{ path }}} -type d -exec chown {{{ FILEUID }}} {} \;
        {{% else %}}
        if [ ! -f {{{ path }}} ]; then
            mkdir -p "$(dirname '{{{ path }}}')"
            touch {{{ path }}}
        fi
        chown {{{ FILEUID }}} {{{ path }}}
        {{% endif %}}
    {{% endif %}}
{{% endfor %}}
