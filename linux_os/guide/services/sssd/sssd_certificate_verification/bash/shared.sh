# platform = multi_platform_ol,multi_platform_rhel,multi_platform_fedora
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_instantiate_variables("var_sssd_certificate_verification_digest_function") }}}

MAIN_CONF="/etc/sssd/conf.d/certificate_verification.conf"

{{{ bash_ensure_ini_config("$MAIN_CONF /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf", "sssd", "certificate_verification", "ocsp_dgst = $var_sssd_certificate_verification_digest_function") }}}

if [ -e "$MAIN_CONF" ]; then
    chown root:root "$MAIN_CONF"
	chmod 600 "$MAIN_CONF"
fi
