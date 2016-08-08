# platform = Red Hat Enterprise Linux 6
#
# Disable cpuspeed for all run levels
#
/sbin/chkconfig --level 0123456 cpuspeed off

#
# Stop cpuspeed if currently running
#
/sbin/service cpuspeed stop
