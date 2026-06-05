# platform = multi_platform_debian

{{{ bash_replace_or_append(chrony_conf_path, '^user', '_chrony', '%s %s', cce_identifiers=cce_identifiers) }}}
