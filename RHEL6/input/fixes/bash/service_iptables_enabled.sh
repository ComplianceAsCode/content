#
# Enable iptables for all run levels
#
chkconfig --level 0123456 iptables on

#
# Start iptables if not currently running
#
service iptables start
