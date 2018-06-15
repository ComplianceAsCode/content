# platform = multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_authorized_local_users_regex

# never delete the root user
default_os_user="root"

# add users sidamd, orasid, sapadm and oracle if needed
userlist="root"

# if /sapmnt is a directory or a symbolic link to a directory,
# then try to add SAP system users to the userlist
if [ -d "/sapmnt" ] ; then 
	# if /sapmnt/SID exists, add sidadm to the userlist
	sapmntSIDlist=$(find /sapmnt/ -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]$')
	for i in $sapmntSIDlist ; do
		SID=${i:8:3}
		userlist="$userlist|$(echo "$SID" | sed -e 's/\(.*\)/\L\1/')adm"
	done

	# try to get brspace from directories /sapmnt/SID/exe (SAP binaries of old structure)
	# and /sapmnt/SID/exe/<codepage>/<platform> (SAP binaries of new structure)
	brspacelist=$(find /sapmnt/ -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]/exe/brspace$' \
 		-o -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]/exe/\(\|n\)uc/[a-z0-9_]+/brspace$')

	# if brspace exist in any of the above directory of a SID, add orasid to the userlist 
	for i in $brspacelist ; do
        	SID=${i:8:3}
        	userlist="$userlist|ora$(echo "$SID" | sed -e 's/\(.*\)/\L\1/')"
	done

	# if owner of any brspace file is oracle, add oracle to the userlist
	oracle=false
	for i in $brspacelist ; do
        	if [ $(ls -ld $i | awk '{print $3}') = "oracle" ]; then
                	oracle=true
        	fi
	done
	if test "$oracle" = true ; then
        	userlist="$userlist|oracle"
	fi
fi

# if /usr/sap/hostctrl is a directory or a symbolic linkd to a directory, add sapadm to the list
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
