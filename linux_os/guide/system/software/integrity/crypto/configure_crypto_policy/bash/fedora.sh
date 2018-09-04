# platform = multi_platform_fedora

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

populate var_system_crypto_policy

update-crypto-policies --set ${var_system_crypto_policy}
