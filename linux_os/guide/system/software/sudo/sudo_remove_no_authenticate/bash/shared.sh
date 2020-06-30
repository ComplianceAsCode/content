# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_debian,multi_platform_ubuntu,multi_platform_ol

sed -i '/^#/!s/\(.*\)![Aa][Uu][Tt][Hh][Ee][Nn][Tt][Ii][Cc][Aa][Tt][Ee]\(.*\)/\1\2/g' /etc/sudoers /etc/sudoers.d/*
