#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

if grep -q "^PASS_MIN_LEN" {{{ login_defs_path }}}; then
	sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/" {{{ login_defs_path }}}
else
	echo "PASS_MIN_LEN 12" >> {{{ login_defs_path }}}
fi
