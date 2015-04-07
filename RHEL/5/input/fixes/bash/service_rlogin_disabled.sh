#
# Disable rlogin for all run levels
#
/sbin/chkconfig --level 0123456 rlogin off

#
# Stop rlogin if currently running
#
/sbin/service rlogin stop 1>/dev/null
