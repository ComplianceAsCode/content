# platform = Red Hat Enterprise Linux 7
grep -q ^DefaultZone= /etc/firewalld/firewalld.conf && \
  sed -i "s/DefaultZone=.*/DefaultZone=drop/g" /etc/firewalld/firewalld.conf
if ! [ $? -eq 0 ]; then
    echo "DefaultZone=drop" >> /etc/firewalld/firewalld.conf
fi
