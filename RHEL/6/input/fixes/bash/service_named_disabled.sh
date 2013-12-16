#
# Disable named for all run levels
#
chkconfig --level 0123456 named off

#
# Stop named if currently running
#
service named stop
