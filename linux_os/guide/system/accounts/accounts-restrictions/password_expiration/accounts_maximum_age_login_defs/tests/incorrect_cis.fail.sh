#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis
# variables = var_accounts_maximum_age_login_defs=365

rm -f {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        375" > {{{ login_defs_path }}}
