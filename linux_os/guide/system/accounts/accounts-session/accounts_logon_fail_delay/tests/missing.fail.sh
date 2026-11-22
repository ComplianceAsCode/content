#!/bin/bash
# profiles = stig

if grep -q 'FAIL_DELAY' {{{ login_defs_path }}}; then
	sed -i '/^.*FAIL_DELAY.*/d' {{{ login_defs_path }}}
fi
