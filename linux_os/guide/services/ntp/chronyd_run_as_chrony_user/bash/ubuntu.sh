# platform = multi_platform_ubuntu

{{{ bash_replace_or_append(chrony_conf_path, '^user', '_chrony', '%s %s', cce_identifiers=cce_identifiers) }}}
