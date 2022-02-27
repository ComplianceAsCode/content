# platform = multi_platform_ol,multi_platform_sle

sed -i '/pam_succeed_if/d' /etc/pam.d/sudo
