# platform = multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_authorized_local_users_regex

# never delete the root user
default_os_user="root"

# add users sidamd, orasid, sapadm and oracle if needed
userlist="root"
sapmnt_SID_stem="/sapmnt/[A-Z][A-Z0-9][A-Z0-9]"
oracle_SID_stem="/oracle/[A-Z][A-Z0-9][A-Z0-9]"

# if owner of any directory or file in the given list is the user oracle, return 1.
# otherwise return 0. 
# Usage: is_owner_oracle "${list[@]}"
function is_owner_oracle {
	local path_list=("$@")
	local is_oracle=0
	for path in $path_list ; do
		if [ $(ls -ld $path | awk '{print $3}') = "oracle" ]; then
			is_oracle=1
		fi
	done
	echo "$is_oracle"
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
	if test "$(is_owner_oracle "${path_to_brspace_list[@]}")" = 1 ; then userlist="$userlist|oracle" ; fi
fi

# if owner of any /oracle/SID directory is oracle, add oracle to the userlist
# the user oracle could be added twice in the userlist, but it is harmlos to the final result
if [ -d "/oracle" ] ; then
	path_oracle_SID_list=$(find /oracle/ -regex "^$oracle_SID_stem$")
	if test "$(is_owner_oracle "${path_oracle_SID_list[@]}")" = 1 ; then userlist="$userlist|oracle" ; fi
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
