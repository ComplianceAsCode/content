MANAGEMENT_IP=$(/sbin/ifconfig | grep inet | grep -v 127.0.0.1 | cut -d: -f2 | awk '{ print $1}' | head -1 | cut -d. -f1-2)
sed -i '/sshd/d' /etc/hosts.allow
echo "sshd: ${MANAGEMENT_IP}.: spawn /bin/echo SSHD accessed on \$(/bin/date) from %h>>/var/log/host.access" | tee -a /etc/hosts.allow &>/dev/null
