# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux


{{{ bash_replace_or_append(chrony_conf_path, '^port', '0', '%s %s') }}}
