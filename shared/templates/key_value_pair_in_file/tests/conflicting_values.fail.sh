#!/bin/bash

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{% endif %}}

mkdir -p $(dirname {{{ PATH }}})
touch {{{ PATH }}}

sed -i "/{{{ KEY }}}/d" "{{{ PATH }}}"
echo "{{{ KEY }}}{{{ SEP }}}{{{ TEST_CORRECT_VALUE }}}" >> "{{{ PATH }}}"
echo "{{{ KEY }}}{{{ SEP }}}{{{ TEST_WRONG_VALUE }}}" >> "{{{ PATH }}}"
