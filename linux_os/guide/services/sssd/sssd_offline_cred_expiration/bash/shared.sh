# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_OPT="offline_credentials_expiration"
SSSD_OPT_VAL=1
PAM_REGEX="[[:space:]]*\[pam]"
PAM_OPT_REGEX="${PAM_REGEX}([^\n\[]*\n+)+?[[:space:]]*${SSSD_OPT}"

# Try find [pam] and offline_credentials_expiration in sssd.conf, if it exists
# set it to 1, if it doesn't exist add it, if [pam] section doesn't exist add
# the section and the configuration option.
if grep -qzosP $PAM_OPT_REGEX $SSSD_CONF; then
	sed -i "s/${SSSD_OPT}[^(\n)]*/${SSSD_OPT} = ${SSSD_OPT_VAL}/" $SSSD_CONF
elif grep -qs $PAM_REGEX $SSSD_CONF; then
	sed -i "/$PAM_REGEX/a ${SSSD_OPT} = ${SSSD_OPT_VAL}" $SSSD_CONF
else
	mkdir -p /etc/sssd
	touch $SSSD_CONF
	echo -e "[pam]\n${SSSD_OPT} = ${SSSD_OPT_VAL}" >> $SSSD_CONF
fi
