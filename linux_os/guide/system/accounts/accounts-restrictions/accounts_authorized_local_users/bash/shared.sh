# platform = multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_authorized_local_users_regex") }}}

# never delete the root user
default_os_user="root"

# delete users that is in /etc/passwd but neither in default_os_user
# nor in var_accounts_authorized_local_users_regex
for username in $( sed 's/:.*//' /etc/passwd ) ; do
	if [[ ! "$username" =~ ($default_os_user|$var_accounts_authorized_local_users_regex) ]];
        then
		userdel $username ;
	fi
done
