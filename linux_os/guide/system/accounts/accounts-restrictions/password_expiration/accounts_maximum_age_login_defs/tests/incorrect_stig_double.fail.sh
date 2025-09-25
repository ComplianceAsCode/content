#!/bin/bash
{{% if product == "ubuntu2404" %}}
# platform = Not Applicable
{{% else %}}
# profiles = xccdf_org.ssgproject.content_profile_stig
{{% endif %}}
# variables = var_accounts_maximum_age_login_defs=60


rm -f {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        60" > {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        120" >> {{{ login_defs_path }}}
