# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# packages = authselect,pam
# remediation = none

authselect select --force minimal
rm -f /etc/pam.d/system-auth
dnf reinstall -y pam
