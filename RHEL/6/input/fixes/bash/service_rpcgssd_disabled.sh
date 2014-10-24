#
# Disable rpcgssd for all run levels
#
/sbin/chkconfig --level 0123456 rpcgssd off

#
# Stop rpcgssd if currently running
#
/sbin/service rpcgssd stop
