#!/bin/bash
#

mkdir -p $(dirname {{{ FILEPATH }}} )
touch {{{ FILEPATH }}}
chmod -R 0777 {{{ FILEPATH }}}
