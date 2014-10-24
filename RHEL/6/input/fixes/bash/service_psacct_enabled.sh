#
# Enable psacct for all run levels
#
/sbin/chkconfig --level 0123456 psacct on

#
# Start psacct if not currently running
#
/sbin/service psacct start
