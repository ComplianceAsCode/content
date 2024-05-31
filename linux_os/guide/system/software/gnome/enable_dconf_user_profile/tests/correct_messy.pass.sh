#!/bin/bash
# platform = multi_platform_ubuntu

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

cat > /etc/dconf/profile/user <<EOF

user-db:user
system-db:site
system-db:distro
system-db:local

EOF
