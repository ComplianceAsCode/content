# platform = multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_authorized_local_users

# never delete the root user
default_os_user="root"

# delete users that is in /etc/passwd but neither in the var_accounts_authorized_local_users
# nor in default_os_user
for username in $( sed 's/:.*//' /etc/passwd ) ; do
	if [[ ! "$username" =~ ($default_os_user|$var_accounts_authorized_local_users) ]]; then
		userdel $username ; 
	fi
done

