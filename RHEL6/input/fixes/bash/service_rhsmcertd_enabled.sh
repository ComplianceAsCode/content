#
# Enable rhsmcertd for all run levels
#
chkconfig --level 0123456 rhsmcertd on

#
# Start rhsmcertd if not currently running
#
service rhsmcertd start
