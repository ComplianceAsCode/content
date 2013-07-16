#
# Enable psacct for all run levels
#
chkconfig --level 0123456 psacct on

#
# Start psacct if not currently running
#
service psacct start
