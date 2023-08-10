#!/bin/bash
# platform = multi_platform_ol,multi_platform_ubuntu,Red Hat Enterprise Linux 7

{{% if product in ["sle12", "sle15"] or 'ubuntu' in product %}}
{{% set pam_lastlog_path = "/etc/pam.d/login" %}}
{{% else %}}
{{% set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{% endif %}}

rm -f {{{ pam_lastlog_path }}}
echo "session     [default=1]                pam_lastlog.so nowtmp showfailed" >> {{{ pam_lastlog_path }}}
