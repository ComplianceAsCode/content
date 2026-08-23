# platform = multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_debian,multi_platform_fedora

{{{ bash_instantiate_variables("var_pam_wheel_group_for_su") }}}

# Workaround for https://github.com/OpenSCAP/openscap/issues/2242: Use full
# path to groupadd command to avoid the issue with the command not being found.
if ! grep -q "^${var_pam_wheel_group_for_su}:[^:]*:[^:]*:[^:]*" /etc/group; then
    /usr/sbin/groupadd ${var_pam_wheel_group_for_su}
fi

# group must be empty
gpasswd -M '' ${var_pam_wheel_group_for_su}
