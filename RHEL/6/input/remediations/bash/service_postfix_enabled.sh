# platform = Red Hat Enterprise Linux 6
#
# Enable postfix for all run levels
#
/sbin/chkconfig --level 0123456 postfix on

#
# Start postfix if not currently running
#
/sbin/service postfix start
