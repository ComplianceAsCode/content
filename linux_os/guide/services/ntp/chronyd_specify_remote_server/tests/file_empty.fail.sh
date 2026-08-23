#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

rm -rf /etc/chrony/conf.d
rm -rf /etc/chrony/sources.d

echo "" > {{{ chrony_conf_path }}}
