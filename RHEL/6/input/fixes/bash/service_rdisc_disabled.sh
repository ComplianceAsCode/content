#
# Disable rdisc for all run levels
#
/sbin/chkconfig --level 0123456 rdisc off

#
# Stop rdisc if currently running
#
/sbin/service rdisc stop
