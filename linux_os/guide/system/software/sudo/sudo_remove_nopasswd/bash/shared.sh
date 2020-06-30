# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_debian,multi_platform_ubuntu,multi_platform_ol

sed -i '/^#/!s/\(.*\)[Nn][Oo][Pp][Aa][Ss][Ss][Ww][Dd][:][ ]\(.*\)/\1\2/g' /etc/sudoers /etc/sudoers.d/*
