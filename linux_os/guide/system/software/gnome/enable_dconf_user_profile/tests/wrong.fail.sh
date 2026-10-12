#!/bin/bash
# packages = dconf
# platform = multi_platform_opensuse,multi_platform_ubuntu

cat > /etc/dconf/profile/gdm <<EOF
user-db:user
system-db:local
EOF
{{% if product not in ['opensuse16', 'sle15', 'sle16'] %}}
cat > /etc/dconf/profile/user <<EOF
user-db:user
system-db:gdm
EOF
{{% endif %}}
