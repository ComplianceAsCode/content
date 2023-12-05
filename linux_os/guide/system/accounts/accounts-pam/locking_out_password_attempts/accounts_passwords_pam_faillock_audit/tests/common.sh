# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle
pam_files=("password-auth" "system-auth")

authselect create-profile testingProfile --base-on minimal

CUSTOM_PROFILE_DIR="/etc/authselect/custom/testingProfile"

for file in ${pam_files[@]}; do
	if grep -q "pam_faillock\.so.*audit" "$CUSTOM_PROFILE_DIR/$file" ; then
		sed -i --follow-symlinks "/pam_faillock\.so.*audit/d" "$CUSTOM_PROFILE_DIR/$file"
	fi
done

authselect select --force custom/testingProfile

truncate -s 0 /etc/security/pam_faillock.conf
