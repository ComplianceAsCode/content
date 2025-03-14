#!/bin/bash
{{% if PACKAGES %}}
# packages = {{{PACKAGES}}}
{{% endif %}}

{{% set GROUPS=GROUP.split("|") %}}
{{% if GROUPS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple groupowners"
exit 1;
{{% else %}}
{{% for grp in GROUPS %}}
{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
echo "Create specific tests for this rule because of regex groupowner"
exit 1;
{{% elif RECURSIVE %}}
find -L {{{ path }}} -type d -exec chgrp {{{ grp }}} {} \;
{{% else %}}
chgrp {{{ grp }}} {{{ path }}}
{{% endif %}}
{{% else %}}
if [ ! -f {{{ path }}} ]; then
    mkdir -p "$(dirname '{{{ path }}}')"
    touch {{{ path }}}
fi
chgrp {{{ grp }}} {{{ path }}}
{{% endif %}}
{{% endfor %}}
{{% endfor %}}
{{% endif %}}
