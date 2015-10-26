# platform = Red Hat Enterprise Linux 6
#
# Disable rhsmcertd for all run levels
#
/sbin/chkconfig --level 0123456 rhsmcertd off

#
# Stop rhsmcertd if currently running
#
/sbin/service rhsmcertd stop
