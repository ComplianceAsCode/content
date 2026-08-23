#!/bin/bash

groupadd group_test
{{% set GROUPS=GID_OR_NAME.split("|") %}}
{{% for grp in GROUPS %}}
getent group "{{{ grp }}}" &>/dev/null || groupadd {{{ grp }}}
{{%- endfor %}}

{{%- if RECURSIVE %}}
{{%- set FIND_RECURSE_ARGS_DEP="" %}}
{{%- elif FILE_REGEX %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 1" %}}
{{%- else %}}
{{%- set FIND_RECURSE_ARGS_DEP="-maxdepth 0" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
touch "{{{ path }}}"/cac_file_groupowner_test_file
{{% if FILE_REGEX %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regextype posix-extended -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chgrp group_test {} \;
{{% elif RECURSIVE %}}
find -P {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type d -exec chgrp group_test {} \;
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
