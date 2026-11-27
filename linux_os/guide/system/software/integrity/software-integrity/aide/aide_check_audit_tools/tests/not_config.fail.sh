#!/bin/bash
# platform = multi_platform_almalinux,multi_platform_fedora,multi_platform_sle,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu
# packages = aide

aide --init

declare -a bins
bins=(
{{% for audit_tool in aide_audit_binaries %}}
"/usr/sbin/{{{ audit_tool }}}"
{{% endfor %}}
)

for theFile in "${bins[@]}"
do
    echo sed -i "s#^.*${theFile}.*##g" {{{ aide_conf_path }}}
done
