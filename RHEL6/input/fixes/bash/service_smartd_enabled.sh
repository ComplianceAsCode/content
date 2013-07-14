#
# Enable smartd for all run levels
#
chkconfig --level 0123456 smartd on

#
# Start smartd if not currently running
#
service smartd start
