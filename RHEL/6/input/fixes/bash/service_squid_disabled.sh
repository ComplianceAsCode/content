#
# Disable squid for all run levels
#
chkconfig --level 0123456 squid off

#
# Stop squid if currently running
#
service squid stop
