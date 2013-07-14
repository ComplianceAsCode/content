#
# Enable cpuspeed for all run levels
#
chkconfig --level 0123456 cpuspeed on

#
# Start cpuspeed if not currently running
#
service cpuspeed start
