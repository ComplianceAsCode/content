# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_instantiate_variables("var_sssd_memcache_timeout") }}}

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf", "nss", "memcache_timeout", "$var_sssd_memcache_timeout") }}}
