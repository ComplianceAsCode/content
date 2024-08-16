# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro

{{{ bash_replace_or_append( pkg_manager_config_file , '^gpgcheck', '1') }}}
