# platform = Red Hat Enterprise Linux 6
#
# Enable irqbalance for all run levels
#
/sbin/chkconfig --level 0123456 irqbalance on

#
# Start irqbalance if not currently running
#
/sbin/service irqbalance start
