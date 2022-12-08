#!/bin/bash

mkdir -p $(dirname {{{ PATH }}})
touch {{{ PATH }}}

sed -i "/{{{ KEY }}}/d" "{{{ PATH }}}"
echo "{{{ KEY }}}{{{ SEP }}}wrong_value" >> "{{{ PATH }}}"
