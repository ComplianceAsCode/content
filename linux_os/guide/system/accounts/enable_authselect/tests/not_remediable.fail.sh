# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_almalinux
# packages = authselect,pam
# remediation = none

authselect select minimal --force
rm -f /etc/pam.d/system-auth
dnf reinstall -y pam
