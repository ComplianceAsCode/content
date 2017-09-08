# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

. /usr/share/scap-security-guide/remediation_functions

package_command install firewalld
populate sshd_listening_port

if [ $sshd_listening_port -ne 22 ] ; then
  firewall-cmd --permanent --service=ssh --add-port=$sshd_listening_port/tcp
  firewall-cmd --permanent --service=ssh --remove-port=22/tcp
fi

firewall-cmd --permanent --zone=public --add-service=ssh
