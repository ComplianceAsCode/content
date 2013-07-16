#
# Enable saslauthd for all run levels
#
chkconfig --level 0123456 saslauthd on

#
# Start saslauthd if not currently running
#
service saslauthd start
