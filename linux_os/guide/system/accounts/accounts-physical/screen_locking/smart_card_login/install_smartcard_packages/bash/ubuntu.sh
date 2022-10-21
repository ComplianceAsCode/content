# platform = multi_platform_ubuntu

DEBIAN_FRONTEND=noninteractive apt-get install -y "libpam-pkcs11"

if [ ! -f /etc/pam_pkcs11/pam_pkcs11.conf ]; then
    cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
fi

sed -i -e 's/debug = true/debug = false/g' -e 's|module = /usr/lib/opensc-pkcs11|module = /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11|' /etc/pam_pkcs11/pam_pkcs11.conf
