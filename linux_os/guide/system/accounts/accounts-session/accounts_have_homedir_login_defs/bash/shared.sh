# platform = multi_platform_all

{{{ set_config_file("/etc/login.defs", "CREATE_HOME", "yes", create=true, insert_after="", insert_before="^\s*CREATE_HOME", insensitive=true) }}}
