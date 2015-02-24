#
# Disable yum-updatesd for all run levels
#
/sbin/chkconfig --level 0123456 yum-updatesd off

#
# Stop yum-updatesd if currently running
#
/sbin/service yum-updatesd stop 1>/dev/null
