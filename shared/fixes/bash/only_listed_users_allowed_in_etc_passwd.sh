# platform = multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_allowed_users_in_etc_passwd

# never delete the root user
default_os_user="root"

# delete users that is in /etc/passwd but neither in the var_allowed_users_in_etc_passwd
# nor in default_os_user
for username in $( sed 's/:.*//' /etc/passwd ) ; do
	if [[ ! "$username" =~ ($default_os_user|$var_allowed_users_in_etc_passwd) ]]; then
		userdel $username ; 
	fi
done

