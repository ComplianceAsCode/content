#
# Enable netfs for all run levels
#
chkconfig --level 0123456 netfs on

#
# Start netfs if not currently running
#
service netfs start
