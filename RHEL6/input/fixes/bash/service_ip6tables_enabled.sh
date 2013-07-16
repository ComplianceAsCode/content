#
# Enable ip6tables for all run levels
#
chkconfig --level 0123456 ip6tables on

#
# Stop ip6tables if currently running
#
service ip6tables start
