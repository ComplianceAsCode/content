#
# Enable oddjobd for all run levels
#
chkconfig --level 0123456 oddjobd on

#
# Start oddjobd if not currently running
#
service oddjobd start
