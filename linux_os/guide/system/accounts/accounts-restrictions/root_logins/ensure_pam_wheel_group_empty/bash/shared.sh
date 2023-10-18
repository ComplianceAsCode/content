# platform = multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_pam_wheel_group_for_su") }}}

if ! grep -q "^${var_pam_wheel_group_for_su}:[^:]*:[^:]*:[^:]*" /etc/group; then
    groupadd ${var_pam_wheel_group_for_su}
fi

# group must be empty
sed -i -E "s/^(${var_pam_wheel_group_for_su}:[^:]*:[^:]*:)[^:]*/\1/g" /etc/group
