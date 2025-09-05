pam_files=("password-auth" "system-auth")

{{%- if ('rhel' in product or 'ol' in families) and product not in ['ol8', 'ol9', 'rhel8', 'rhel9']%}}
# rhel>=10 default profile is now called local
authselect create-profile testingProfile --base-on local
{{%- else %}}
authselect create-profile testingProfile --base-on minimal
{{%- endif %}}

CUSTOM_PROFILE_DIR="/etc/authselect/custom/testingProfile"

for file in ${pam_files[@]}; do
	if grep -q "pam_faillock\.so.*audit" "$CUSTOM_PROFILE_DIR/$file" ; then
		sed -i --follow-symlinks "/pam_faillock\.so.*audit/d" "$CUSTOM_PROFILE_DIR/$file"
	fi
done

authselect select --force custom/testingProfile

truncate -s 0 /etc/security/pam_faillock.conf
