#
# Disable rdisc for all run levels
#
chkconfig --level 0123456 rdisc off

#
# Stop rdisc if currently running
#
service rdisc stop
