#
# Enable psacct for all run levels
#
chkconfig --level 0123456 psacct on

#
# Stop psacct if currently running
#
service psacct start
