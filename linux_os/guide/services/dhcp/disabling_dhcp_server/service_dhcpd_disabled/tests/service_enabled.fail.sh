#!/bin/bash
{{% if product in ['sle15'] %}}
    {{% set pkp_name="dhcp" %}}
    {{% set svc_name="dhcpd" %}}
{{% elif product in ['debian12', 'ubuntu2404'] %}}
    {{% set pkp_name="isc-dhcp-server" %}}
    {{% set svc_name="isc-dhcp-server" %}}
{{% else %}}
    {{% set pkp_name="dhcp-server" %}}
    {{% set svc_name="dhcpd" %}}
{{% endif %}}
# packages = {{{ pkp_name }}}

# Simple configuration for dhcp so we can start the service
cat << EOF >> /etc/dhcp/dhcpd.conf
subnet 192.168.122.0 netmask 255.255.255.248 {
}
EOF

systemctl start {{{ svc_name }}}
systemctl enable {{{ svc_name }}}
