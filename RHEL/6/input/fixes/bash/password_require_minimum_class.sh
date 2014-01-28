grep -q minclass /etc/pam.d/system-auth
if [ $? = "0" ]; then
    sed --follow-symlinks -i "/pam_cracklib.so/s/minclass=[0-4]/minclass=3/" /etc/pam.d/system-auth
else
    sed --follow-symlinks -i "/pam_cracklib.so/s/pam_cracklib.so /pam_cracklib.so minclass=3 /" /etc/pam.d/system-auth
fi
