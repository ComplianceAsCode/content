#!/bin/bash
# profiles = stig

if grep -q 'FAIL_DELAY' {{{ login_defs_path }}}; then
	sed -i 's/^.*FAIL_DELAY.*/FAIL_DELAY 4/' {{{ login_defs_path }}}
else
	echo 'FAIL_DELAY 4' >> {{{ login_defs_path }}}
fi
