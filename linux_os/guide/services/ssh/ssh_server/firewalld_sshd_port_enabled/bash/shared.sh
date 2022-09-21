# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

{{{ bash_package_install("firewalld") }}}

{{{ bash_instantiate_variables("firewalld_sshd_zone") }}}

{{% if product in ['rhel9'] %}}
  {{% set network_config_path = "/etc/NetworkManager/system-connections/${interface}.nmconnection" %}}
  {{% set zone_param= "zone" %}}
{{% else %}}
  {{% set network_config_path = "/etc/sysconfig/network-scripts/ifcfg-${interface}" %}}
  {{% set zone_param= "ZONE" %}}
{{% endif %}}

# This assumes that firewalld_sshd_zone is one of the pre-defined zones
if [ ! -f "/etc/firewalld/zones/${firewalld_sshd_zone}.xml" ]; then
    cp "/usr/lib/firewalld/zones/${firewalld_sshd_zone}.xml" "/etc/firewalld/zones/${firewalld_sshd_zone}.xml"
fi
if ! grep -q 'service name="ssh"' "/etc/firewalld/zones/${firewalld_sshd_zone}.xml"; then
    sed -i '/<\/description>/a \
  <service name="ssh"/>' "/etc/firewalld/zones/${firewalld_sshd_zone}.xml"
fi

available_nmconfig_profiles=()
# Check if any eth interface is bounded to the zone with SSH service enabled
nic_bound=false
readarray -t dev_interface_list < <(ip link show up | cut -d ' ' -f2 | cut -d ':' -s -f1 | grep -E '^(en|eth)')
for interface in "${dev_interface_list[@]}"; do
    if [ -f {{{ network_config_path }}} ]; then
      available_nmconfig_profiles+=("$interface")
    fi
    if grep -qi "{{{ zone_param }}}=$firewalld_sshd_zone" "{{{ network_config_path }}}"; then
        nic_bound=true
        break;
    fi
done

{{% if product in ['rhel9'] %}}
# Check NetworkManager profiles by looking at interface's altnames
if [ $nic_bound = false ]; then
  readarray -t altname_interface_list < <(ip link show up | grep -oP '(?<=altname )(.*)')
  for interface in "${altname_interface_list[@]}"; do
    if [ -f {{{ network_config_path }}} ]; then
      available_nmconfig_profiles+=("$interface")
    fi
    if grep -qi "{{{ zone_param }}}=$firewalld_sshd_zone" "{{{ network_config_path }}}"; then
        nic_bound=true
        break;
    fi
done
fi
{{% endif %}}

ip link show
ls /etc/NetworkManager/system-connections/

if [ $nic_bound = false ];then
    # Add first Network profile to SSH enabled zone
    interface="${available_nmconfig_profiles[0]}"

    if ! firewall-cmd --state -q; then
        {{{ bash_replace_or_append(network_config_path, '^{{{ zone_param }}}=', "$firewalld_sshd_zone", '%s=%s') | indent(8) }}}
    else
        # If firewalld service is running, we need to do this step with firewall-cmd
        # Otherwise firewalld will communicate with NetworkManage and will revert assigned zone
        # of NetworkManager managed interfaces upon reload
        firewall-cmd --permanent --zone="$firewalld_sshd_zone" --add-interface="$interface"
        firewall-cmd --reload
    fi
fi
