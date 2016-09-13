# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
#
# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate sshd_listening_port

if [ $sshd_listening_port -ne 22] ; then
  firewall-cmd --permanent --add-port=$sshd_listening_port/tcp
else
  firewall-cmd --permanent --add-service=ssh
fi
