# platform = multi_platform_rhel,multi_platform_fedora
# packages = authselect,pam

rm -f /etc/pam.d/{fingerprint-auth,password-auth,postlogin,smartcard-auth,system-auth}
dnf reinstall -y pam
