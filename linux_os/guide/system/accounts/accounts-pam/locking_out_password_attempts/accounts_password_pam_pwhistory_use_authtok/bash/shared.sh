# platform = multi_platform_all

{{% if 'debian' in product or 'ubuntu' in product or 'sle' in product or 'slmicro' in product %}}
{{{ bash_pam_pwhistory_parameter_value("/etc/pam.d/common-password", "use_authtok") }}}
{{% else %}}
{{{ bash_ensure_authselect_custom_profile() }}}
pam_profile="$(head -1 /etc/authselect/authselect.conf)"
if grep -Pq -- '^custom\/' <<< "$pam_profile"; then
    pam_profile_path="/etc/authselect/$pam_profile"
else
    pam_profile_path="/usr/share/authselect/default/$pam_profile"
fi

for authselect_file in "$pam_profile_path"/password-auth "$pam_profile_path"/system-auth; do
    if ! grep -Pq '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' "$authselect_file"; then
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwhistory\.so\s+.*)$/& use_authtok/g' "$authselect_file"
    fi
done

authselect apply-changes
{{% endif %}}
