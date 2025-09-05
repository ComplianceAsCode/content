# platform = multi_platform_ol

{{{ bash_instantiate_variables("var_accounts_authorized_local_users_regex") }}}

# never delete the root user
default_os_user="root"

# add users sidamd, orasid, sapadm and oracle if needed
userlist="root"
sapmnt_SID_stem="/sapmnt/[A-Z][A-Z0-9][A-Z0-9]"
oracle_SID_stem="/oracle/[A-Z][A-Z0-9][A-Z0-9]"

# if owner of any directory or file in the given list is the user oracle,
# add the user oracle to the variable userlist. 
# Usage: verify_oracle_user_to_userlist "$path_list"
# Note: this function might modify the value of the global variable userlist
function verify_oracle_user_to_userlist {
	local path_list="$1"
	local is_oracle=no
	for path in $path_list ; do
		if [ "$(stat -c %U -- "$path")" = "oracle" ]; then
			is_oracle=yes
		fi
	done
	if test "$is_oracle" = yes ; then
		userlist="$userlist|oracle" ;
	fi
} 

# if /sapmnt is a directory or a symbolic link to a directory,
# then try to add SAP system users to the userlist
if [ -d "/sapmnt" ] ; then 
	# if /sapmnt/SID exists, add sidadm to the userlist
	path_sapmnt_SID_list=$(find /sapmnt/ -regex "^$sapmnt_SID_stem$")
	for path_sapmnt_SID in $path_sapmnt_SID_list ; do
		SID=${path_sapmnt_SID:8:3}
		userlist="$userlist|$(echo "$SID" | sed -e 's/\(.*\)/\L\1/')adm"
	done

	# try to get brspace from directories /sapmnt/SID/exe (SAP binaries of old structure)
	# and /sapmnt/SID/exe/<codepage>/<platform> (SAP binaries of new structure)
	path_to_brspace_list=$(find /sapmnt/ -regex "^$sapmnt_SID_stem/exe/\(\|\(\|n\)uc/[a-z0-9_]+/\)brspace$")

	# if brspace exist in any of the above directory of a SID, add orasid to the userlist 
	for path_to_brspace in $path_to_brspace_list ; do
		SID=${path_to_brspace:8:3}
		userlist="$userlist|ora$(echo "$SID" | sed -e 's/\(.*\)/\L\1/')"
	done

	# if owner of any brspace file is oracle, add oracle to the userlist
	verify_oracle_user_to_userlist "$path_to_brspace_list"
fi

# if owner of any /oracle/SID directory is oracle, add oracle to the userlist
# the user oracle could be added twice in the userlist, but it is harmlos to the final result
if [ -d "/oracle" ] ; then
	path_oracle_SID_list=$(find /oracle/ -regex "^$oracle_SID_stem$")
	verify_oracle_user_to_userlist "$path_oracle_SID_list"
fi

# if /usr/sap/hostctrl is a directory or a symbolic link to a directory, add sapadm to the list
if [ -d /usr/sap/hostctrl ] ; then
	userlist="$userlist|sapadm"
fi

# delete users that is in /etc/passwd but neither in the userlist
# nor in default_os_user nor in the var_accounts_authorized_local_users_regex
default_os_user=^$default_os_user$
userlist=^$userlist$
for username in $( sed 's/:.*//' /etc/passwd ) ; do
	if [[ ! "$username" =~ ($default_os_user|$userlist|$var_accounts_authorized_local_users_regex) ]]; then
		userdel $username ; 
	fi
done
