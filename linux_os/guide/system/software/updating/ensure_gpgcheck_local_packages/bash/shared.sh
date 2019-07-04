# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '{{{ pkg_manager_config_file }}}' '^localpkg_gpgcheck' '1' '@CCENUM@'
