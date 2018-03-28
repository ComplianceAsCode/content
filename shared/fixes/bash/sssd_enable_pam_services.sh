# platform = multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

SSSD_SERVICES_PAM_REGEX="^[[:space:]]*\[sssd]([^\n]*\n+)+?[[:space:]]*services.*pam.*$"
SSSD_SERVICES_REGEX="^[[:space:]]*\[sssd]([^\n]*\n+)+?[[:space:]]*services.*$"
SSSD_PAM_SERVICES="[sssd]
services = pam"
SSSD_CONF="/etc/sssd/sssd.conf"

# If there is services line with pam, good
# If there is services line without pam, append pam
# If not echo services line with pam
grep -q "$SSSD_SERVICES_PAM_REGEX" $SSSD_CONF || \
	grep -q "$SSSD_SERVICES_REGEX" $SSSD_CONF && \
	sed -i "s/$SSSD_SERVICES_REGEX/&, pam/" $SSSD_CONF || \
	echo "$SSSD_PAM_SERVICES" >> $SSSD_CONF

