# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_ubuntu,multi_platform_almalinux

{{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}

{{{ bash_replace_or_append('/etc/rsyslog.conf', '^\*\.\*', "@@$rsyslog_remote_loghost_address", '%s %s', cce_identifiers=cce_identifiers) }}}
