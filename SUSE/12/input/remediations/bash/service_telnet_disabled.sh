# platform = SUSE Enterprise 12
grep -qi disable /etc/xinetd.d/telnet && \
  sed -i "s/disable.*/disable         = yes/gI" /etc/xinetd.d/telnet

#
# Disable telnet.socket for all systemd targets
#
systemctl disable telnet.socket

#
# Stop telnet.socket if currently running
#
systemctl stop telnet.socket
