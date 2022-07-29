{{% if 'ubuntu' in product %}}
configuration_files=("common-password")
{{% elif product in ['ol8', 'ol9', 'rhel8', 'rhel9'] %}}
configuration_files=("password-auth" "system-auth")
{{% else %}}
configuration_files=("system-auth")
{{% endif %}}


{{% if product in ['ol8', 'ol9', 'rhel8', 'rhel9'] %}}
authselect create-profile testingProfile --base-on minimal 

for file in ${configuration_files[@]}; do
	sed -i --follow-symlinks "/pam_pwquality\.so/d" \
		"/etc/authselect/custom/testingProfile/$file"
done
authselect select --force custom/testingProfile
{{% else %}}
for file in ${configuration_files[@]}; do
	sed -i --follow-symlinks "/pam_pwquality\.so/d" "/etc/pam.d/$file"
done
{{% endif%}}

truncate -s 0 /etc/security/pwquality.conf
