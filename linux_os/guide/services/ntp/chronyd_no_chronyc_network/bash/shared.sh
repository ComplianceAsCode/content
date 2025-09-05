# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol


{{{ bash_replace_or_append("/etc/chrony.conf", '^cmdport', '0', '@CCENUM@', '%s %s') }}}
