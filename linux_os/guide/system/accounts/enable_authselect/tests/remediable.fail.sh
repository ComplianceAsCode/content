# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_almalinux
# packages = authselect,pam

rm -f /etc/pam.d/{fingerprint-auth,password-auth,postlogin,smartcard-auth,system-auth}
dnf reinstall -y pam
