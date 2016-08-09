# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_minclass

grep -q minclass /etc/pam.d/system-auth
if [ $? = "0" ]; then
    sed --follow-symlinks -i "/pam_cracklib.so/s/minclass=[0-$var_password_pam_minclass]/minclass=$var_password_pam_minclass/" /etc/pam.d/system-auth
else
    sed --follow-symlinks -i "/pam_cracklib.so/s/pam_cracklib.so /pam_cracklib.so minclass=$var_password_pam_minclass /" /etc/pam.d/system-auth
fi
