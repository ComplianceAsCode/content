# platform = Red Hat Enterprise Linux 7

if ! `grep -q "^session.*pam_lastlog.so" /etc/pam.d/postlogin` ; then
	echo "session     [default=1]   pam_lastlog.so nowtmp showfailed" >> /etc/pam.d/postlogin
	echo "session     optional      pam_lastlog.so silent noupdate showfailed" >> /etc/pam.d/postlogin
else
	sed -i --follow-symlinks "/pam_lastlog.so/d" /etc/pam.d/postlogin
	echo "session     [default=1]   pam_lastlog.so nowtmp showfailed" >> /etc/pam.d/postlogin
        echo "session     optional      pam_lastlog.so silent noupdate showfailed" >> /etc/pam.d/postlogin
fi
