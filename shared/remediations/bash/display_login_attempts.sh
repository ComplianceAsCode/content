# platform = Red Hat Enterprise Linux 7

if ! `grep -q ^[^#].*pam_succeed_if.*showfailed /etc/pam.d/postlogin` ; then
  if ! grep `^session.*pam_succeed_if.so /etc/pam.d/postlogin` ; then
    echo "session     [default=1]   pam_lastlog.so nowtmp showfailed" >> /etc/pam.d/postlogin
    echo "session     optional      pam_lastlog.so silent noupdate showfailed" >> /etc/pam.d/postlogin
  else
    sed -i '/^session.*pam_succeed_if.so/a session\t    optional\t  pam_lastlog.so silent noupdate showfailed' /etc/pam.d/postlogin
    sed -i '/^session.*pam_succeed_if.so/a session\t    [default=1]\t  pam_lastlog.so nowtmp showfailed' /etc/pam.d/postlogin
  fi
else
  sed -i "s/session[ ]*\[default=1][ ]*pam_lastlog.so.*/session     [default=1]   pam_lastlog.so nowtmp showfailed/g" /etc/pam.d/postlogin
  sed -i "s/session[ ]*optional[ ]*pam_lastlog.so.*/session     optional      pam_lastlog.so silent noupdate showfailed/g" /etc/pam.d/postlogin
fi
