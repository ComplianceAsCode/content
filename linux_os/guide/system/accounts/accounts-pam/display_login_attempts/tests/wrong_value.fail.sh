#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

{{% set pam_lastlog_path = "/etc/pam.d/postlogin" %}}

rm -f {{{ pam_lastlog_path }}}

echo "session     optional                   pam_umask.so silent" >> {{{ pam_lastlog_path }}}
echo "session     [success=1 default=ignore] pam_succeed_if.so service !~ gdm* service !~ su* quiet" >> {{{ pam_lastlog_path }}}
echo "session     [default=1]                pam_lastlog.so wrong_value" >> {{{ pam_lastlog_path }}}
echo "session     optional                   pam_lastlog.so silent noupdate showfailed" >> {{{ pam_lastlog_path }}}
