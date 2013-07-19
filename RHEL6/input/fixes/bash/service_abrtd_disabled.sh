#
# Disable abrtd for all run levels
#
chkconfig --level 0123456 abrtd off

#
# Stop abrtd if currently running
#
service abrtd stop
