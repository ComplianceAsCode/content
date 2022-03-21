# platform = multi_platform_all


{{% if product in ["sle15", "sle12"] -%}}
if ! grep -q "^password.*required.*pam_unix.so.*sha512" /etc/pam.d/common-password ; then
   sed -i --follow-symlinks "/^password.*required.*pam_unix.so/ s/$/ sha512/" /etc/pam.d/common-password
fi
{{%- else -%}}
AUTH_FILES[0]="/etc/pam.d/system-auth"
{{%- if product == "rhel7" %}}
AUTH_FILES[1]="/etc/pam.d/password-auth"
{{%- endif %}}
for pamFile in "${AUTH_FILES[@]}"
do
	if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" $pamFile; then
		sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" $pamFile
	fi
done
{{%- endif %}}

