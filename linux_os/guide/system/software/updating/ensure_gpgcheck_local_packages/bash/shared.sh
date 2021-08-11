# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_replace_or_append('{{{ pkg_manager_config_file }}}', '^localpkg_gpgcheck', '1', '@CCENUM@') }}}
