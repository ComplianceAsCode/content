#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

if grep -q 'FAIL_DELAY' {{{ login_defs_path }}}; then
	sed -i '/^.*FAIL_DELAY.*/d' {{{ login_defs_path }}}
fi
