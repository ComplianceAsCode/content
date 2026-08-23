#!/bin/bash

if grep -q "^UMASK" {{{ login_defs_path }}}; then
	sed -i "s/^UMASK.*/umask 077/" {{{ login_defs_path }}}
else
	echo "umask 077" >> {{{ login_defs_path }}}
fi
