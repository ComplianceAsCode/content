# platform = Red Hat Enterprise Linux 6
#
# Disable dovecot for all run levels
#
/sbin/chkconfig --level 0123456 dovecot off

#
# Stop dovecot if currently running
#
/sbin/service dovecot stop
