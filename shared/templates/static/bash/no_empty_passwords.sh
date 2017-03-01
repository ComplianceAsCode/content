# platform = Red Hat Enterprise Linux 5, multi_platform_rhel, multi_platform_fedora
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
