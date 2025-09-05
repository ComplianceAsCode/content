# platform = multi_platform_rhel,multi_platform_fedora
# packages = authselect,pam
# remediation = none

authselect select --force minimal
rm -f /etc/pam.d/system-auth
dnf reinstall -y pam
