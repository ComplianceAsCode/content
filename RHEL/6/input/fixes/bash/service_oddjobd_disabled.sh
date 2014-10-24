#
# Disable oddjobd for all run levels
#
/sbin/chkconfig --level 0123456 oddjobd off

#
# Stop oddjobd if currently running
#
/sbin/service oddjobd stop
