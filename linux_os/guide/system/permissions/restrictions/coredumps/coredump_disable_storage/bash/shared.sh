# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
. /usr/share/scap-security-guide/remediation_functions
include_lineinfile

coredump_config_set Storage none
