#
# Disable rpcidmapd for all run levels
#
chkconfig --level 0123456 rpcidmapd off

#
# Stop rpcidmapd if currently running
#
service rpcidmapd stop
