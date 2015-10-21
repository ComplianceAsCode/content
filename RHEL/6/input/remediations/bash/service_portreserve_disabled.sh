# platform = Red Hat Enterprise Linux 6
#
# Disable portreserve for all run levels
#
/sbin/chkconfig --level 0123456 portreserve off

#
# Stop portreserve if currently running
#
/sbin/service portreserve stop
