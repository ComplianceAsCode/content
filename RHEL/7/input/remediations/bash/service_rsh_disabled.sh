# platform = Red Hat Enterprise Linux 7
grep -qi disable /etc/xinetd.d/rsh && \
  sed -i "s/disable.*/disable         = yes/gI" /etc/xinetd.d/rsh

#
# Disable rsh.socket for all systemd targets
#
systemctl disable rsh.socket

#
# Stop rsh.socket if currently running
#
systemctl stop rsh.socket
