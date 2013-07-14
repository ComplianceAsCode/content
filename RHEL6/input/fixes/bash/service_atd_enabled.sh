#
# Enable atd for all run levels
#
chkconfig --level 0123456 atd on

#
# Start atd if not currently running
#
service atd start
