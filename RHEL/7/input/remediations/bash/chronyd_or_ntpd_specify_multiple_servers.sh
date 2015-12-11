# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers

if ! `/usr/sbin/pidof ntpd`; then
  if [ `grep -c '^server' /etc/chrony.conf` -lt 2 ]; then 
    if ! `grep -q '#[[:space:]]*server' /etc/chrony.conf` ; then
      for i in `echo "$var_multiple_time_servers" | tr ',' '\n'` ; do
        echo -ne "\nserver $i iburst" >> /etc/chrony.conf
      done
    else
      sed -i 's/#[ ]*server/server/g' /etc/chrony.conf
    fi
  fi
else
  if [ `grep -c '^server' /etc/ntp.conf` -lt 2 ]; then
    if ! `grep -q '#[[:space:]]*server' /etc/ntp.conf` ; then
      for i in `echo "$var_multiple_time_servers" | tr ',' '\n'` ; do
        echo -ne "\nserver $i iburst" >> /etc/ntp.conf
      done
    else
      sed -i 's/#[ ]*server/server/g' /etc/ntp.conf
    fi
  fi
fi
