# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

# Install required packages
package_command install esc
package_command install pam_pkcs11

# Enable pcscd.socket systemd activation socket
service_command enable pcscd.socket

# Enable smartcard authentication (but allow also other ways
# to login not to possibly cut off the system in question)
/usr/sbin/authconfig --enablesmartcard --updateall

# Define constants to be reused below
SP="[:space:]"
PAM_PKCS11_CONF="/etc/pam_pkcs11/pam_pkcs11.conf"

# Ensure OCSP is turned on in $PAM_PKCS11_CONF
# 1) First replace any occurrence of 'none' value of 'cert_policy' key setting with the correct configuration
sed -i "s/^[$SP]*cert_policy[$SP]\+=[$SP]\+none;/\t\tcert_policy = ca, ocsp_on, signature;/g" "$PAM_PKCS11_CONF"
# 2) Then append 'ocsp_on' value setting to each 'cert_policy' key in $PAM_PKCS11_CONF configuration line,
# which does not contain it yet
sed -i "/ocsp_on/! s/^[$SP]*cert_policy[$SP]\+=[$SP]\+\(.*\);/\t\tcert_policy = \1, ocsp_on;/" "$PAM_PKCS11_CONF"
