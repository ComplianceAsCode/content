#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
sed -i --follow-symlinks '/nullok/d' /etc/pam.d/common-password
{{% else %}}
sed -i --follow-symlinks '/nullok/d' /etc/pam.d/system-auth
sed -i --follow-symlinks '/nullok/d' /etc/pam.d/password-auth
{{% endif %}}
