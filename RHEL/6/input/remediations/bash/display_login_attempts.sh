# platform = Red Hat Enterprise Linux 6
sed -i --follow-symlinks '/pam_limits.so/a session\t    required\t  pam_lastlog.so showfailed' /etc/pam.d/system-auth
