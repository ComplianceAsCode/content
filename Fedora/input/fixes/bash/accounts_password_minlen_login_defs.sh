# Include source function library.
. /usr/share/scap-security-guide/functions
source ./templates/support.sh
populate var_accounts_password_minlen_login_defs

grep -q ^PASS_MIN_LEN /etc/login.defs && \
sed -i "s/PASS_MIN_LEN.*/PASS_MIN_LEN\t$var_accounts_password_minlen_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]
then
  append_to_file "PASS_MIN_LEN\t$var_accounts_password_minlen_login_defs" "/etc/login.defs"
fi
