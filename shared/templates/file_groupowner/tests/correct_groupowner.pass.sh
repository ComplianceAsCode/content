#!/bin/bash

{{% set GROUPS=GID_OR_NAME.split("|") %}}
{{% for grp in GROUPS %}}
getent group "{{{ grp }}}" &>/dev/null || groupadd {{{ grp }}}
{{%- endfor %}}

{{% if GROUPS|length > 1 %}}
echo "Create specific tests for this rule because of mulitple groupowners"
exit 1;
{{% else %}}

{{%- if RECURSIVE %}}
{{%- set FIND_RECURSE_ARGS_DEP="" %}}
{{%- set FIND_RECURSE_ARGS_SYM="" %}}
{{%- else %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 1" %}}
{{%- set FIND_RECURSE_ARGS_SYM="-L" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
touch "{{{ path }}}"/cac_file_groupowner_test_file
{{% if FILE_REGEX %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chgrp {{{ GID_OR_NAME }}} {} \;
{{% elif RECURSIVE %}}
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} -type d -exec chgrp {{{ GID_OR_NAME }}} {} \;
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
