#!/bin/bash
#
# remediation = bash

if grep -q "^CREATE_HOME" {{{ login_defs_path }}}; then
	sed -i "s/^CREATE_HOME.*/#CREATE_HOME yes/" {{{ login_defs_path }}}
else
	echo "#CREATE_HOME yes" >> {{{ login_defs_path }}}
fi
