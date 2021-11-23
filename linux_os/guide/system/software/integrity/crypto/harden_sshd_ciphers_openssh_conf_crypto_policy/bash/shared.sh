# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora

{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}

{{{ set_config_file(
        path="/etc/crypto-policies/back-ends/openssh.config",
        parameter="Ciphers",
        value="${sshd_approved_ciphers}",
        create=true,
        insensitive=false,
        prefix_regex="^.*"
	)
}}}
