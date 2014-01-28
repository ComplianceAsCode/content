#
# Disable cpuspeed for all run levels
#
chkconfig --level 0123456 cpuspeed off

#
# Stop cpuspeed if currently running
#
service cpuspeed stop
