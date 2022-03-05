# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel

{{{ bash_instantiate_variables("var_sssd_ssh_known_hosts_timeout") }}}

{{{ bash_sssd_set_option("[ssh]", "sssd.conf", "ssh_known_hosts_timeout", "$var_sssd_ssh_known_hosts_timeout") }}}
