#!/bin/bash

if grep -q "^UMASK" {{{ login_defs_path }}}; then

	sed -i "s/^UMASK.*/UMASK 077/" {{{ login_defs_path }}}
else
	echo "UMASK 077" >> {{{ login_defs_path }}}
fi
