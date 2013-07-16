#
# Enable rpcgssd for all run levels
#
chkconfig --level 0123456 rpcgssd on

#
# Start rpcgssd if not currently running
#
service rpcgssd start
