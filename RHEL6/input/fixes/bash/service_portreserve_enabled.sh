#
# Enable portreserve for all run levels
#
chkconfig --level 0123456 portreserve on

#
# Start portreserve if not currently running
#
service portreserve start
