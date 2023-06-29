# platform = multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_pam_wheel_group_for_su") }}}

if ! grep -q "^${var_pam_wheel_group_for_su}:[^:]*:[^:]*:[^:]*" /etc/group; then
    groupadd ${var_pam_wheel_group_for_su}
fi

# group must be empty
grp_memb=$(groupmems -g ${var_pam_wheel_group_for_su} -l)
if [ -n "${grp_memb}" ]; then
    for memb in ${grp_memb}; do
        deluser ${memb} ${var_pam_wheel_group_for_su}
    done
fi
