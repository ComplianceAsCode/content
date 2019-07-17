# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

. /usr/share/scap-security-guide/remediation_functions

include_lineinfile
tmux_config_set "status" "off"
