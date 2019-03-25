# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

# Perform /etc/pam_pkcs11/pam_pkcs11.conf settings below
# Define selected constants for later reuse
SP="[:space:]"
PAM_PKCS11_CONF="/etc/pam_pkcs11/pam_pkcs11.conf"

package_install pam_pkcs11

# Ensure OCSP is turned on in $PAM_PKCS11_CONF
# 1) First replace any occurrence of 'none' value of 'cert_policy' key setting with the correct configuration
sed -i "s/^[$SP]*cert_policy[$SP]\+=[$SP]\+none;/\t\tcert_policy = ca, ocsp_on, signature;/g" "$PAM_PKCS11_CONF"
# 2) Then append 'ca' value setting to each 'cert_policy' key in $PAM_PKCS11_CONF configuration line,
# which does not contain it yet
sed -i "/ca/! s/^[$SP]*cert_policy[$SP]\+=[$SP]\+\(.*\);/\t\tcert_policy = \1, ca;/" "$PAM_PKCS11_CONF"

true
