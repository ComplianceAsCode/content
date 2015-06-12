grep -q minclass /etc/pam.d/system-auth
if [ $? = "0" ]; then
    sed --follow-symlinks -i "/pam_pwquality.so/s/minclass=[0-4]/minclass=3/" /etc/pam.d/system-auth
else
    sed --follow-symlinks -i "/pam_pwquality.so/s/pam_pwquality.so /pam_pwquality.so minclass=3 /" /etc/pam.d/system-auth
fi
