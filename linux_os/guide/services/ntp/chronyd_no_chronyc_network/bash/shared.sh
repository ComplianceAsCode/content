# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol


{{{ bash_replace_or_append(chrony_conf_path, '^cmdport', '0', '%s %s') }}}
