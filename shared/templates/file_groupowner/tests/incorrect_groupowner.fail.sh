#!/bin/bash

groupadd group_test

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
find {{{ FIND_RECURSE_ARGS_SYM }}} {{{ path }}} {{{ FIND_RECURSE_ARGS_DEP }}} -type f -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chgrp group_test {} \;
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
