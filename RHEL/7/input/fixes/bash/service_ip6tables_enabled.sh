#
# Enable ip6tables for all run levels
#
chkconfig --level 0123456 ip6tables on

#
# Start ip6tables if not currently running
#
service ip6tables start
