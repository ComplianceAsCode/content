# platform = multi_platform_all

sed -i '/pam_succeed_if/d' /etc/pam.d/sudo
