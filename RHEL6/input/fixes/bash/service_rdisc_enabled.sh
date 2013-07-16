#
# Enable rdisc for all run levels
#
chkconfig --level 0123456 rdisc on

#
# Start rdisc if not currently running
#
service rdisc start
