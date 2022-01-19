#!/bin/bash
# platform = Red Hat Enterprise Linux 7,multi_platform_ol,multi_platform_ubuntu

{{% if product in ["sle12", "sle15"] or 'ubuntu' in product %}}
{{% set pam_lastlog_path = "/etc/pam.d/login" %}}
{{% else %}}
{{% set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{% endif %}}

rm -f {{{ pam_lastlog_path }}}

cat <<EOF > {{{ pam_lastlog_path }}}
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.


session     [success=1 default=ignore] pam_succeed_if.so service !~ gdm* service !~ su* quiet
session     [default=1]   pam_lastlog.so nowtmp showfailed
session     optional      pam_lastlog.so silent noupdate showfailed
EOF
