#!/bin/bash

groupadd group_test
{{% set GROUPS=GID_OR_NAME.split("|") %}}
{{% for grp in GROUPS %}}
getent group "{{{ grp }}}" &>/dev/null || groupadd {{{ grp }}}
{{%- endfor %}}

{{% if RECURSIVE %}}
{{% set FIND_RECURSE_ARGS="" %}}
{{% else %}}
{{% set FIND_RECURSE_ARGS="-maxdepth 1" %}}
{{% endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex groupowner"
exit 1;
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chgrp group_test {} \;
{{% else %}}
chgrp group_test {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chgrp group_test {{{ path }}}
{{% endif %}}
{{% endfor %}}
