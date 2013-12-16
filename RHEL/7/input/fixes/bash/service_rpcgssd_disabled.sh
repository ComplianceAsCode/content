#
# Disable rpcgssd for all run levels
#
chkconfig --level 0123456 rpcgssd off

#
# Stop rpcgssd if currently running
#
service rpcgssd stop
