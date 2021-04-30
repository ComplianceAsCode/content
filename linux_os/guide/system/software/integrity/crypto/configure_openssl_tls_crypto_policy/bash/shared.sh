# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

CONFIG_FILE=/etc/crypto-policies/back-ends/opensslcnf.config

replace_or_append "$CONFIG_FILE" '^MinProtocol' 'TLSv1.2' '@CCENUM@'

update-crypto-policies
