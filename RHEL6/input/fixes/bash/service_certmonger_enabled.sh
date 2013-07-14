#
# Enable certmonger for all run levels
#
chkconfig --level 0123456 certmonger on

#
# Start certmonger if not currently running
#
service certmonger start
