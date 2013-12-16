#
# Disable dovecot for all run levels
#
chkconfig --level 0123456 dovecot off

#
# Stop dovecot if currently running
#
service dovecot stop
