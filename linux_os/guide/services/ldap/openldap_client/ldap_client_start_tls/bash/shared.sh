# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux


# Use LDAP for authentication
{{{ bash_replace_or_append('/etc/sysconfig/authconfig', '^USELDAPAUTH', 'yes', '%s=%s', cce_identifiers=cce_identifiers) }}}

# Configure client to use TLS for all authentications
{{{ bash_replace_or_append('/etc/nslcd.conf', '^ssl', 'start_tls', '%s %s', cce_identifiers=cce_identifiers) }}}
