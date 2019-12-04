# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_wrlinux
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth
