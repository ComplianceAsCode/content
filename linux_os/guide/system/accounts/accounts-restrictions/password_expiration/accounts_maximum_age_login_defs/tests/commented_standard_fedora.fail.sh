#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard
# platform = multi_platform_fedora
# variables = var_accounts_maximum_age_login_defs=90

rm -f {{{ login_defs_path }}}
echo '#PASS_MAX_DAYS 90' > {{{ login_defs_path }}}
