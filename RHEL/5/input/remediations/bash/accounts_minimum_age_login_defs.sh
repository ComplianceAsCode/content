. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_minimum_age_login_defs

grep -q ^PASS_MIN_DAYS /etc/login.defs && \
  sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS     $var_accounts_minimum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MIN_DAYS      $var_accounts_minimum_age_login_defs" >> /etc/login.defs
fi

USERACCT=$(egrep -v "^\+|^#" /etc/passwd | cut -d":" -f1)
for SYS_USER in ${USERACCT}; do
	if [ $(grep -c ${SYS_USER} /etc/shadow) != 0 ]; then
		passwd -n $var_accounts_minimum_age_login_defs ${SYS_USER} &>/dev/null
	fi
done
