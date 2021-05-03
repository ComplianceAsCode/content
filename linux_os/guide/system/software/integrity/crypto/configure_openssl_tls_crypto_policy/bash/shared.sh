# platform = Red Hat Enterprise Linux 8
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{{ set_config_file(
        path="/etc/crypto-policies/back-ends/opensslcnf.config",
        parameter="MinProtocol",
        value="TLSv1.2",
        create=true,
        insert_after="",
        insert_before="",
        insensitive=false,
        separator="=",
        separator_regex="\s*=\s*",
        prefix_regex="^"
	)
}}}
