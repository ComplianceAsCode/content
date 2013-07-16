#
# Enable rpcidmapd for all run levels
#
chkconfig --level 0123456 rpcidmapd on

#
# Start rpcidmapd if not currently running
#
service rpcidmapd start
