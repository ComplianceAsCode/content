# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

{{{ bash_instantiate_variables("var_sssd_ldap_tls_ca_dir") }}}

{{{ bash_sssd_ldap_config(parameter="ldap_tls_cacertdir", value="$var_sssd_ldap_tls_ca_dir") }}}
