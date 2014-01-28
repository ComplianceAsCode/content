#
# Disable oddjobd for all run levels
#
chkconfig --level 0123456 oddjobd off

#
# Stop oddjobd if currently running
#
service oddjobd stop
