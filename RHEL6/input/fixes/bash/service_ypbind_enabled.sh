#
# Enable ypbind for all run levels
#
chkconfig --level 0123456 ypbind on

#
# Start ypbind if not currently running
#
service ypbind start
