#
# Enable abrtd for all run levels
#
chkconfig --level 0123456 abrtd on

#
# Start abrtd if not currently running
#
service abrtd start
