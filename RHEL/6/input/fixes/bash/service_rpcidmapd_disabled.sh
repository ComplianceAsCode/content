# platform = Red Hat Enterprise Linux 6
#
# Disable rpcidmapd for all run levels
#
/sbin/chkconfig --level 0123456 rpcidmapd off

#
# Stop rpcidmapd if currently running
#
/sbin/service rpcidmapd stop
