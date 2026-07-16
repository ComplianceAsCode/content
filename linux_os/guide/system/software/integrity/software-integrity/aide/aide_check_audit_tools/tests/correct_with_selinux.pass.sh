#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu,multi_platform_almalinux
# packages = aide

declare -a bins
bins=(
{{% for audit_tool in aide_audit_binaries %}}
"/usr/sbin/{{{ audit_tool }}}"
{{% endfor %}}
)

echo >> {{{ aide_conf_path }}}
for theFile in "${bins[@]}"
do
    echo "$theFile p+i+n+u+g+s+b+acl+selinux+xattrs+sha512" >> {{{ aide_conf_path }}}
done
