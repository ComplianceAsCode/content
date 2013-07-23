#
# Enable irqbalance for all run levels
#
chkconfig --level 0123456 irqbalance on

#
# Start irqbalance if not currently running
#
service irqbalance start
