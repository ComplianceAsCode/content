# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

if ! `rpm -q --quiet chrony` && ! `rpm -q --quiet ntp-`; then
  {{{ bash_package_install("chrony") | indent(2) }}}
  service_command enable chronyd
elif `rpm -q --quiet chrony`; then
  if ! [ `/usr/sbin/pidof ntpd` ] ; then
    service_command enable chronyd
  fi
else
  service_command enable ntpd
fi
