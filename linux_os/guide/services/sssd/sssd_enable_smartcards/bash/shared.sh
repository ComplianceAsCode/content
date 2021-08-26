# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_rhv,multi_platform_ol,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_OPT="pam_cert_auth"
SSSD_OPT_VAL=true
PAM_REGEX="[[:space:]]*\[pam]"
PAM_OPT_REGEX="${PAM_REGEX}([^\n\[]*\n+)+?[[:space:]]*${SSSD_OPT}"

if grep -qzosP $PAM_OPT_REGEX $SSSD_CONF; then
	sed -i "s/${SSSD_OPT}[^(\n)]*/${SSSD_OPT} = ${SSSD_OPT_VAL}/" $SSSD_CONF
elif grep -qs $PAM_REGEX $SSSD_CONF; then
	sed -i "/$PAM_REGEX/a ${SSSD_OPT} = ${SSSD_OPT_VAL}" $SSSD_CONF
else
	mkdir -p /etc/sssd
	touch $SSSD_CONF
	echo -e "[pam]\n${SSSD_OPT} = ${SSSD_OPT_VAL}" >> $SSSD_CONF
fi
