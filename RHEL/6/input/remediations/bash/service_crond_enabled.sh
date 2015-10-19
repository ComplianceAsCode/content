# platform = Red Hat Enterprise Linux 6
#
# Enable crond for all run levels
#
/sbin/chkconfig --level 0123456 crond on

#
# Start crond if not currently running
#
/sbin/service crond start
