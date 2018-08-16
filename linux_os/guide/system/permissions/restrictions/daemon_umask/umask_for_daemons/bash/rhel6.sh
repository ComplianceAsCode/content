# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_umask_for_daemons

grep -q ^umask /etc/init.d/functions && \
  sed -i "s/umask.*/umask $var_umask_for_daemons/g" /etc/init.d/functions
if ! [ $? -eq 0 ]; then
    echo "umask $var_umask_for_daemons" >> /etc/init.d/functions
fi
