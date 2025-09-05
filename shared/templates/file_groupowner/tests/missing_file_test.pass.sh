#!/bin/bash

{{% for path in FILEPATH %}}
    {{% if MISSING_FILE_PASS %}}
        rm -f {{{ path }}}
    {{% else %}}
        {{% if IS_DIRECTORY and FILE_REGEX %}}
        echo "Create specific tests for this rule because of regex"
        {{% elif IS_DIRECTORY and RECURSIVE %}}
        find -L {{{ path }}} -type d -exec chgrp {{{ FILEGID }}} {} \;
        {{% else %}}
        if [ ! -f {{{ path }}} ]; then
            mkdir -p "$(dirname '{{{ path }}}')"
            touch {{{ path }}}
        fi
        chgrp {{{ FILEGID }}} {{{ path }}}
        {{% endif %}}
    {{% endif %}}
{{% endfor %}}
