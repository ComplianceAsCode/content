# platform = Red Hat Enterprise Linux 7

# Install required packages
if ! rpm --quiet -q pam_pkcs11; then yum -y -d 1 install pam_pkcs11; fi

if grep "^\s*cert_policy" /etc/pam_pkcs11/pam_pkcs11.conf | grep -qv "ocsp_on"; then
	sed -i "/^\s*#/! s/cert_policy.*/cert_policy = ca, ocsp_on, signature;/g" /etc/pam_pkcs11/pam_pkcs11.conf
fi
