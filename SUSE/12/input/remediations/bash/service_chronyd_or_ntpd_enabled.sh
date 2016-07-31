# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

if ! `rpm -q --quiet chrony` && ! `rpm -q --quiet ntp-`; then
  package_command install chrony
  service_command enable chronyd
elif `rpm -q --quiet chrony`; then
  if ! [ `/usr/sbin/pidof ntpd` ] ; then
    service_command enable chronyd
  fi
else
  service_command enable ntpd
fi
