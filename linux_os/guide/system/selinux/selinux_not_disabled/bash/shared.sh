# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

# Check current SELinux state in config file
selinux_current_state=""
if [ -f "/etc/selinux/config" ]; then
    selinux_current_state=$(grep -oP '^\s*SELINUX=\K(enforcing|permissive|disabled)' /etc/selinux/config || true)
fi

# Only remediate if SELinux is disabled or not configured
# If already set to enforcing or permissive, it's compliant - preserve the current state
if [ "$selinux_current_state" != "enforcing" ] && [ "$selinux_current_state" != "permissive" ]; then
    # SELinux is disabled or not configured, set to permissive as a conservative approach
    {{{ bash_selinux_config_set(parameter="SELINUX", value="permissive", rule_id=rule_id) }}}
    fixfiles onboot
fi
