# platform = Red Hat Virtualization 4,multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Use LDAP for authentication
replace_or_append '/etc/sysconfig/authconfig' '^USELDAPAUTH' 'yes' '@CCENUM@' '%s=%s'

# Configure client to use TLS for all authentications
replace_or_append '/etc/nslcd.conf' '^ssl' 'start_tls' '@CCENUM@' '%s %s'
