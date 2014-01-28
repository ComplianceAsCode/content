#
# Disable cups for all run levels
#
chkconfig --level 0123456 cups off

#
# Stop cups if currently running
#
service cups stop
