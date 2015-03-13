#
# Disable rsh for all run levels
#
/sbin/chkconfig --level 0123456 rsh off

#
# Stop rsh if currently running
#
/sbin/service rsh stop 1>/dev/null
