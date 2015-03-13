#
# Disable rexec for all run levels
#
/sbin/chkconfig --level 0123456 rexec off

#
# Stop rexec if currently running
#
/sbin/service rexec stop 1>/dev/null
