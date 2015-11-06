# platform = Red Hat Enterprise Linux 7

if ! `grep -q showfailed /etc/pam.d/postlogin` ; then
  sed -i '/pam_succeed_if.so/a session\t    optional\t  pam_lastlog.so silent noupdate showfailed' /etc/pam.d/postlogin
  sed -i '/pam_succeed_if.so/a session\t    [default=1]\t  pam_lastlog.so nowtmp showfailed' /etc/pam.d/postlogin
fi
