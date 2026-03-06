#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

sed -i '/server 0.pool.ntp.org/d' /etc/chrony/conf.d/*.conf
sed -i '/server 0.pool.ntp.org/d' /etc/chrony/sources.d/*.sources

echo "server 0.pool.ntp.org" > {{{ chrony_conf_path }}}
