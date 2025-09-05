#!/bin/bash
{{% if product == "ubuntu2404" %}}
# platform = Not Applicable
{{% else %}}
# profiles = xccdf_org.ssgproject.content_profile_stig
{{% endif %}}


rm -f {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        60" > {{{ login_defs_path }}}
echo "PASS_MAX_DAYS        30" >> {{{ login_defs_path }}}
