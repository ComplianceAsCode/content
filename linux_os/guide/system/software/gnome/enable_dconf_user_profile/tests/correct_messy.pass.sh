#!/bin/bash
# packages = dconf
# platform = multi_platform_opensuse,multi_platform_ubuntu

cat > /etc/dconf/profile/gdm <<EOF
# this
  user-db:user
# is
# really
# messy
# system-db:gdm
  system-db:gdm
# stuff
EOF

{{% if product not in ['opensuse16', 'sle15', 'sle16'] %}}
cat > /etc/dconf/profile/user <<EOF

user-db:user
system-db:site
system-db:distro
system-db:local

EOF
{{% endif %}}
