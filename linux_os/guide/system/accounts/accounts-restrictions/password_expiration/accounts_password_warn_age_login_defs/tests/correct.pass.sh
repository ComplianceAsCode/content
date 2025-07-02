#!/bin/bash

grep -q "^PASS_WARN_AGE" {{{ login_defs_path }}} && \
  sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE\t7/g" {{{ login_defs_path }}}
if ! [ $? -eq 0 ]; then
	echo -e "PASS_WARN_AGE\t7" >> {{{ login_defs_path }}}
fi
