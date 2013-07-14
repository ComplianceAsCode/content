#
# Enable dovecot for all run levels
#
chkconfig --level 0123456 dovecot on

#
# Start dovecot if not currently running
#
service dovecot start
