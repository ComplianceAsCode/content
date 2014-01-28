#
# Disable acpid for all run levels
#
chkconfig --level 0123456 acpid off

#
# Stop acpid if currently running
#
service acpid stop
