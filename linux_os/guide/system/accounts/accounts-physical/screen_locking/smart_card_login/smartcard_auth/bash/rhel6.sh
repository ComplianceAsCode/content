# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions

# Install required packages
yum -y install esc
yum -y install pam_pkcs11

# Enable pcscd service
service_command enable pcscd

# Configure the expected /etc/pam.d/system-auth{,-ac} settings directly
#
# The code below will configure system authentication in the way smart card
# logins will be enabled, but also user login(s) via other method to be allowed
#
# NOTE: In contrast to Red Hat Enterprise Linux 7 version of this remediation
#       script (based on the testing) it does NOT seem to be possible to use
#       the 'authconfig' command to perform the remediation for us. Because:
#
#       * calling '/usr/sbin/authconfig --enablesmartcard --update'
#	  does not update all the necessary files, while
#
#	* calling '/usr/sbin/authconfig --enablesmartcard --updateall'
#	  discards the necessary changes on /etc/pam_pkcs11/pam_pkcs11.conf
#	  performed subsequently below
#
#	Therefore we configure /etc/pam.d/system-auth{,-ac} settings directly.
#

# Define system-auth config location
SYSTEM_AUTH_CONF="/etc/pam.d/system-auth"
# Define expected 'pam_env.so' row in $SYSTEM_AUTH_CONF
PAM_ENV_SO="auth.*required.*pam_env.so"

# Define 'pam_succeed_if.so' row to be appended past $PAM_ENV_SO row into $SYSTEM_AUTH_CONF
SYSTEM_AUTH_PAM_SUCCEED="\
auth        \[success=1 default=ignore\] pam_succeed_if.so service notin \
login:gdm:xdm:kdm:xscreensaver:gnome-screensaver:kscreensaver quiet use_uid"
# Define 'pam_pkcs11.so' row to be appended past $SYSTEM_AUTH_PAM_SUCCEED
# row into SYSTEM_AUTH_CONF file
SYSTEM_AUTH_PAM_PKCS11="\
auth        \[success=done authinfo_unavail=ignore ignore=ignore default=die\] \
pam_pkcs11.so card_only"

# Define smartcard-auth config location
SMARTCARD_AUTH_CONF="/etc/pam.d/smartcard-auth"
# Define 'pam_pkcs11.so' auth section to be appended past $PAM_ENV_SO into $SMARTCARD_AUTH_CONF
SMARTCARD_AUTH_SECTION="\
auth        [success=done ignore=ignore default=die] pam_pkcs11.so wait_for_card card_only"
# Define expected 'pam_permit.so' row in $SMARTCARD_AUTH_CONF
PAM_PERMIT_SO="account.*required.*pam_permit.so"
# Define 'pam_pkcs11.so' password section
SMARTCARD_PASSWORD_SECTION="\
password    required      pam_pkcs11.so"

# First Correct the SYSTEM_AUTH_CONF configuration
if ! grep -q 'pam_pkcs11.so' "$SYSTEM_AUTH_CONF"
then
	# Append (expected) pam_succeed_if.so row past the pam_env.so into SYSTEM_AUTH_CONF file
	sed -i --follow-symlinks -e '/^'"$PAM_ENV_SO"'/a '"$SYSTEM_AUTH_PAM_SUCCEED" "$SYSTEM_AUTH_CONF"
	# Append (expected) pam_pkcs11.so row past the pam_succeed_if.so into SYSTEM_AUTH_CONF file
	sed -i --follow-symlinks -e '/^'"$SYSTEM_AUTH_PAM_SUCCEED"'/a '"$SYSTEM_AUTH_PAM_PKCS11" "$SYSTEM_AUTH_CONF"
fi

# Then also correct the SMARTCARD_AUTH_CONF
if ! grep -q 'pam_pkcs11.so' "$SMARTCARD_AUTH_CONF"
then
	# Append (expected) SMARTCARD_AUTH_SECTION row past the pam_env.so into SMARTCARD_AUTH_CONF file
	sed -i --follow-symlinks -e '/^'"$PAM_ENV_SO"'/a '"$SMARTCARD_AUTH_SECTION" "$SMARTCARD_AUTH_CONF"
	# Append (expected) SMARTCARD_PASSWORD_SECTION row past the pam_permit.so into SMARTCARD_AUTH_CONF file
	sed -i --follow-symlinks -e '/^'"$PAM_PERMIT_SO"'/a '"$SMARTCARD_PASSWORD_SECTION" "$SMARTCARD_AUTH_CONF"
fi

# Perform /etc/pam_pkcs11/pam_pkcs11.conf settings below
# Define selected constants for later reuse
SP="[:space:]"
PAM_PKCS11_CONF="/etc/pam_pkcs11/pam_pkcs11.conf"

# Ensure OCSP is turned on in $PAM_PKCS11_CONF
# 1) First replace any occurrence of 'none' value of 'cert_policy' key setting with the correct configuration
# On Red Hat Enterprise Linux 6 a space isn't required between 'cert_policy' key and value assignment !!!
sed -i "s/^[$SP]*cert_policy=none;/    cert_policy=ca, ocsp_on, signature;/g" "$PAM_PKCS11_CONF"

# 2) Then append 'ocsp_on' value setting to each 'cert_policy' key in $PAM_PKCS11_CONF configuration line,
# which does not contain it yet
# On Red Hat Enterprise Linux 6 a space isn't required between 'cert_policy' key and value assignment !!!
sed -i "/ocsp_on/! s/^[$SP]*cert_policy=\(.*\);/    cert_policy=\1, ocsp_on;/" "$PAM_PKCS11_CONF"
