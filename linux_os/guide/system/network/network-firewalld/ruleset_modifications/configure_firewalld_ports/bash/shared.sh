# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low


{{{ bash_package_install("firewalld") }}}


{{{ bash_instantiate_variables("firewalld_sshd_zone") }}}

{{% if product in ['rhel9'] %}}
  {{% set network_config_path = "/etc/NetworkManager/system-connections/${eth_interface_list[0]}.nmconnection" %}}
{{% else %}}
  {{% set network_config_path = "/etc/sysconfig/network-scripts/ifcfg-${eth_interface_list[0]}" %}}
{{% endif %}}

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
    if grep -qi "ZONE=$firewalld_sshd_zone" {{{ network_config_path }}}; then
        nic_bound=true
        break;
    fi
done

if [ $nic_bound = false ];then
    # Add first NIC to SSH enabled zone

    if ! firewall-cmd --state -q; then
        {{% if product in ['rhel9'] %}}
          {{{ bash_replace_or_append(network_config_path, '^zone=', "$firewalld_sshd_zone", '%s=%s') | indent(8) }}}
        {{% else %}}
          {{{ bash_replace_or_append(network_config_path, '^ZONE=', "$firewalld_sshd_zone", '%s=%s') | indent(8) }}}
        {{% endif %}}
    else
        # If firewalld service is running, we need to do this step with firewall-cmd
        # Otherwise firewalld will communicate with NetworkManage and will revert assigned zone
        # of NetworkManager managed interfaces upon reload
        firewall-cmd --permanent --zone=$firewalld_sshd_zone --add-interface=${eth_interface_list[0]}
        firewall-cmd --reload
    fi
fi
