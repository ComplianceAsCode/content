#!/bin/bash
# packages = aide
# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux


cat >/etc/aide.conf <<EOL
All = p+i+n+u+g+s+m+S+sha512+acl+xattrs+selinux
option = yes
/bin p+i+n+u+g+s+m+S+sha512+acl+selinux
/sbin p+i+n+u+g+s+m+S+sha512+acl+selinux
EOL
