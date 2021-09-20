#!/bin/bash
#

mkdir -p $(dirname {{{ FILEPATH }}} )
touch {{{ FILEPATH }}}
chmod -R {{{ FILEMODE }}} {{{ FILEPATH }}}
