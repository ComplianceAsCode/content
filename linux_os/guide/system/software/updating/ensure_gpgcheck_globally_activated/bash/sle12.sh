# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions


replace_or_append "{{{ pkg_manager_config_file }}}" '^gpgcheck' 'on' '@CCENUM@'
replace_or_append "{{{ pkg_manager_config_file }}}" '^repo_gpgcheck' 'on' '@CCENUM@'
replace_or_append "{{{ pkg_manager_config_file }}}" '^pkg_gpgcheck' 'on' '@CCENUM@'
