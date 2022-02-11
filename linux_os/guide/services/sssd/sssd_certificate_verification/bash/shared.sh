# platform = multi_platform_ol,multi_platform_rhel,multi_platform_fedora
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_instantiate_variables("var_sssd_certificate_verification_digest_function") }}}

{{{ bash_sssd_set_option_new("sssd", "certificate_verification", "certificate_verification", "ocsp_dgst = $var_sssd_certificate_verification_digest_function") }}}
