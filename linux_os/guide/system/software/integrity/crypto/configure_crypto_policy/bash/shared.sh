# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8,Red Hat Virtualization 4

# include remediation functions library
. /usr/share/scap-security-guide/remediation_functions

populate var_system_crypto_policy

update-crypto-policies --set ${var_system_crypto_policy}
