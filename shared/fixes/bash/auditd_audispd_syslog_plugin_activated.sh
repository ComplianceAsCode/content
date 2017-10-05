# platform = multi_platform_rhel

grep -q ^active /etc/audisp/plugins.d/syslog.conf && \
  sed -i "s/active.*/active = yes/g" /etc/audisp/plugins.d/syslog.conf
if ! [ $? -eq 0 ]; then
    echo "active = yes" >> /etc/audisp/plugins.d/syslog.conf
fi
