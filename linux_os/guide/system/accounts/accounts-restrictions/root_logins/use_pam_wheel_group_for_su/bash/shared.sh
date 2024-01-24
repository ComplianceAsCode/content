# platform = multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
{{{ bash_instantiate_variables("var_pam_wheel_group_for_su") }}}

PAM_CONF=/etc/pam.d/su

pamstr=$(grep -P '^auth\s+required\s+pam_wheel\.so\s+(?=[^#]*\buse_uid\b)(?=[^#]*\bgroup=)' ${PAM_CONF})
if [ -z "$pamstr" ]; then
    sed -Ei '/^auth\b.*\brequired\b.*\bpam_wheel\.so/d' ${PAM_CONF} # remove any remaining uncommented pam_wheel.so line
    sed -Ei "/^auth\s+sufficient\s+pam_rootok\.so.*$/a auth             required        pam_wheel.so use_uid group=${var_pam_wheel_group_for_su}" ${PAM_CONF}
else
    group_val=$(echo -n "$pamstr" | grep -Eo '\bgroup=[_a-z][-0-9_a-z]*' | cut -d '=' -f 2)
    if [ -z "${group_val}" ] || [ ${group_val} != ${var_pam_wheel_group_for_su} ]; then
        sed -Ei "s/(^auth\s+required\s+pam_wheel.so\s+[^#]*group=)[_a-z][-0-9_a-z]*/\1${var_pam_wheel_group_for_su}/" ${PAM_CONF}
    fi
fi
