#
# Enable named for all run levels
#
chkconfig --level 0123456 named on

#
# Start named if not currently running
#
service named start
