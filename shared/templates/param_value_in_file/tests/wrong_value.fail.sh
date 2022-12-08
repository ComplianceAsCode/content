#!/bin/bash

mkdir -p $(dirname {{{ PATH }}})
touch {{{ PATH }}}

sed -i "/{{{ PARAM }}}/d" "{{{ PATH }}}"
echo "{{{ PARAM }}}{{{ SEP }}}wrong_value" >> "{{{ PATH }}}"
