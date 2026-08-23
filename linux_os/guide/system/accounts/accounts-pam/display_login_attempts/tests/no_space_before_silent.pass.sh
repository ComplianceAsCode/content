#!/bin/bash
# platform = multi_platform_all

{{%- if "sle" in product or "slmicro" in product or "ubuntu" in product %}}
{{% set pam_lastlog_path = "/etc/pam.d/login" %}}
{{% else %}}
{{% set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{% endif %}}

rm -f {{{ pam_lastlog_path }}}

cat <<EOF > {{{ pam_lastlog_path }}}
session     optional                   pam_umask.so silent
session     [success=1 default=ignore] pam_succeed_if.so service !~ gdm* service !~ su* quiet
session     [default=1]                pam_lastlog.so unknown=silent nowtmp showfailed
session     optional                   pam_lastlog.so silent noupdate showfailed
EOF
