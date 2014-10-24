#
# Disable abrtd for all run levels
#
/sbin/chkconfig --level 0123456 abrtd off

#
# Stop abrtd if currently running
#
/sbin/service abrtd stop
