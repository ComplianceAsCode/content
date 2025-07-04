#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis

rm -f {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        365" > {{{ login_defs_path }}}
