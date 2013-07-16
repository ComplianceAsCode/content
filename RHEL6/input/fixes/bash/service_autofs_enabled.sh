#
# Enable autofs for all run levels
#
chkconfig --level 0123456 autofs on

#
# Start autofs if not currently running
#
service autofs start
