#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard
# platform = multi_platform_fedora

rm -f {{{ login_defs_path }}}
echo "PASS_MAX_DAYS 120" > {{{ login_defs_path }}}
