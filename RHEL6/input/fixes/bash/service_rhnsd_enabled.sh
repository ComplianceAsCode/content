#
# Enable rhnsd for all run levels
#
chkconfig --level 0123456 rhnsd on

#
# Start rhnsd if not currently running
#
service rhnsd start
