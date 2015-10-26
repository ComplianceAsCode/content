# platform = Red Hat Enterprise Linux 6
#
# Disable squid for all run levels
#
/sbin/chkconfig --level 0123456 squid off

#
# Stop squid if currently running
#
/sbin/service squid stop
