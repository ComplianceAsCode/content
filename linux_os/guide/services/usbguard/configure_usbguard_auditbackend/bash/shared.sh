# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
{{{ set_config_file(
        path="/etc/usbguard/usbguard-daemon.conf",
        parameter="AuditBackend",
        value="LinuxAudit",
        create=true,
        insert_after="",
        insert_before="",
        insensitive=false,
        separator="=",
        separator_regex="=",
        prefix_regex="^\s*"
	)
}}}
