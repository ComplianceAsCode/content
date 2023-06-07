#!/bin/bash

{{% for path in FILEPATH %}}
{{% if IS_DIRECTORY and FILE_REGEX %}}
echo "Create specific tests for this rule because of regex"
{{% elif IS_DIRECTORY and RECURSIVE %}}
find -L {{{ path }}} -type d -exec chgrp {{{ GID_OR_NAME }}} {} \;
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chgrp {{{ GID_OR_NAME }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
