#!/bin/bash
#

{{% for path in FILEPATH %}}
{{% if IS_DIRECTORY and FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    touch {{{ path }}}
fi
chgrp {{{ FILEGID }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
