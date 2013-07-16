#
# Enable messagebus for all run levels
#
chkconfig --level 0123456 messagebus on

#
# Start messagebus if not currently running
#
service messagebus start
