# platform = Red Hat Enterprise Linux 6
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
