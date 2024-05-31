#!/bin/bash

groupadd group_test

{{%- if RECURSIVE %}}
{{% set FIND_RECURSE_ARGS="" %}}
{{%- else %}}
{{% set FIND_RECURSE_ARGS="-maxdepth 1" %}}
{{%- endif %}}

{{%- if EXCLUDED_FILES %}}
{{% set EXCLUDED_FILES_ARGS="! -name '" + EXCLUDED_FILES|join("' ! -name '") + "'" %}}
{{%- else %}}
{{% set EXCLUDED_FILES_ARGS="" %}}
{{%- endif %}}

{{% for path in FILEPATH %}}
{{% if path.endswith("/") %}}
if [ ! -d {{{ path }}} ]; then
    mkdir -p {{{ path }}}
fi
{{% if FILE_REGEX %}}
find -L {{{ path }}} {{{ FIND_RECURSE_ARGS }}} {{{ EXCLUDED_FILES_ARGS }}} -type f -regex '{{{ FILE_REGEX[loop.index0] }}}' -exec chgrp group_test {} \;
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
