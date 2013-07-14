#
# Enable mdmonitor for all run levels
#
chkconfig --level 0123456 mdmonitor on

#
# Start mdmonitor if not currently running
#
service mdmonitor start
