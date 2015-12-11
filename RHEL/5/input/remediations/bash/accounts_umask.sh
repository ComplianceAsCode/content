. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_user_umask

egrep -li ^[[:blank:]]*umask `find /etc /root /home/* -maxdepth 1 -type f 2>/dev/null` | while read FILE; do
	sed -i "s/\([uU][mM][aA][sS][kK]\s*[=]*\s*\)[0-9]*/\1${var_accounts_user_umask}/" "${FILE}"
done

