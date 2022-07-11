# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_ol,multi_platform_sle,multi_platform_fedora

{{{ set_config_file("/etc/login.defs", "CREATE_HOME", "yes", create=true, insert_after="", insert_before="^\s*CREATE_HOME", insensitive=true) }}}
