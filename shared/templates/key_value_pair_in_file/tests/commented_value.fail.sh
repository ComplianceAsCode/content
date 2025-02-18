#!/bin/bash

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

mkdir -p $(dirname {{{ PATH }}})
touch {{{ PATH }}}

sed -i "/{{{ KEY }}}/d" "{{{ PATH }}}"
echo "# {{{ KEY }}}{{{ SEP }}}{{{ CORRECT_VALUE }}}" >> "{{{ PATH }}}"
