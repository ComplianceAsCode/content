# platform = multi_platform_sle

if ! grep -q "^password.*required.*pam_unix.so.*sha512" /etc/pam.d/common-password ; then
   sed -i --follow-symlinks "/^password.*required.*pam_unix.so/ s/$/ sha512/" /etc/pam.d/common-password
fi
