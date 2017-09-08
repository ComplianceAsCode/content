# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

. /usr/share/scap-security-guide/remediation_functions

package_command install firewalld
populate sshd_listening_port
populate firewalld_sshd_zone

if [ $sshd_listening_port -ne 22 ] ; then
  # Remove all ports from SSH service
  ssh_ports=$(firewall-cmd --permanent --service=ssh --get-ports)
  for port in $ssh_ports; do
      firewall-cmd --permanent --service=ssh --remove-port=$port
  done

  firewall-cmd --permanent --service=ssh --add-port=$sshd_listening_port/tcp
fi

# Return code is 0 even if zone already enables SSH service,
# so we just try to add SSH to the zone fearlessly
firewall-cmd --permanent --zone=$firewalld_sshd_zone --add-service=ssh
