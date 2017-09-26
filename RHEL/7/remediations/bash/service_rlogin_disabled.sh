# platform = Red Hat Enterprise Linux 7
grep -qi disable /etc/xinetd.d/rlogin && \
  sed -i "s/disable.*/disable         = yes/gI" /etc/xinetd.d/rlogin

#
# Disable rlogin.socket for all systemd targets
#
systemctl disable rlogin.socket

#
# Stop rlogin.socket if currently running
#
systemctl stop rlogin.socket
