#
# Enable squid for all run levels
#
chkconfig --level 0123456 squid on

#
# Start squid if not currently running
#
service squid start
