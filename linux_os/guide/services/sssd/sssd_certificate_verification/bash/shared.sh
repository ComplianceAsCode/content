# platform = multi_platform_ol,multi_platform_rhel,multi_platform_fedora,multi_platform_almalinux
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_instantiate_variables("var_sssd_certificate_verification_digest_function") }}}

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_sssd_ensure_default_config("$SSSD_CONF", "$SSSD_CONF_DIR") }}}
{{{ bash_install_sssd_proxy() }}}

MAIN_CONF="$SSSD_CONF_DIR/certificate_verification.conf"

{{{ bash_ensure_ini_config("$MAIN_CONF $SSSD_CONF $SSSD_CONF_DIR/*.conf", "sssd", "certificate_verification", "ocsp_dgst=$var_sssd_certificate_verification_digest_function") }}}

umask $OLD_UMASK
