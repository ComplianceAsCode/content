# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# packages = authselect,pam

rm -f /etc/pam.d/{fingerprint-auth,smartcard-auth,system-auth}
dnf reinstall -y pam
