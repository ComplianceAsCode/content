#!/bin/bash

{{% set GROUPS=GID_OR_NAME.split("|") %}}
{{% for grp in GROUPS %}}
getent group "{{{ grp }}}" &>/dev/null || groupadd {{{ grp }}}
{{%- endfor %}}

{{% if GROUPS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple groupowners"
exit 1;
{{% else %}}
{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex groupowner"
exit 1;
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chgrp {{{ GID_OR_NAME }}} {} \;
{{% else %}}
chgrp {{{ GID_OR_NAME }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chgrp {{{ GID_OR_NAME }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
{{% endif %}}
