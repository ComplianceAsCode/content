# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_instantiate_variables("var_sssd_memcache_timeout") }}}

{{{ bash_sssd_set_option("[nss]", "/etc/sssd/sssd.conf", "memcache_timeout", "$var_sssd_memcache_timeout", "[[:space:]]*\[nss]") }}}
