# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

. /usr/share/scap-security-guide/remediation_functions

package_command install firewalld

populate firewalld_sshd_zone

# This assumes that firewalld_sshd_zone is one of the pre-defined zones
if [ ! -f /etc/firewalld/zones/${firewalld_sshd_zone}.xml ]; then
    cp /usr/lib/firewalld/zones/${firewalld_sshd_zone}.xml /etc/firewalld/zones/${firewalld_sshd_zone}.xml
fi
if ! grep -q 'service name="ssh"' /etc/firewalld/zones/${firewalld_sshd_zone}.xml; then
    sed -i '/<\/description>/a \
  <service name="ssh"/>' /etc/firewalld/zones/${firewalld_sshd_zone}.xml
fi

# Check if any eth interface is bounded to the zone with SSH service enabled
nic_bound=false
eth_interface_list=$(ip link show up | cut -d ' ' -f2 | cut -d ':' -s -f1 | grep -E '^(en|eth)')
for interface in $eth_interface_list; do
    if grep -q "ZONE=$firewalld_sshd_zone" /etc/sysconfig/network-scripts/ifcfg-$interface; then
        nic_bound=true
        break;
    fi
done

if [ $nic_bound = false ];then
    # Add first NIC to SSH enabled zone

    if ! firewall-cmd --state -q; then
        replace_or_append "/etc/sysconfig/network-scripts/ifcfg-${eth_interface_list[0]}" '^ZONE=' "$firewalld_sshd_zone" '@CCENUM@' '%s=%s'
    else
        # If firewalld service is running, we need to do this step with firewall-cmd
        # Otherwise firewalld will comunicate with NetworkManage and will revert assigned zone
        # of NetworkManager managed interfaces upon reload
        firewall-cmd --zone=$firewalld_sshd_zone --add-interface=${eth_interface_list[0]}
        firewall-cmd --reload
    fi
fi
