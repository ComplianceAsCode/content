#
# Enable iptables for all run levels
#
chkconfig --level 0123456 iptables on

#
# Stop iptables if currently running
#
service iptables start
