#
# Enable irqbalance for all run levels
#
chkconfig --level 0123456 irqbalance on

#
# Stop irqbalance if currently running
#
service irqbalance start
