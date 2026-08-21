#!/bin/bash
# packages = firewalld
# platform = multi_platform_all

mkdir -p /etc/firewalld/zones
touch /etc/firewalld/firewalld.conf
if grep -q "^DefaultZone=" /etc/firewalld/firewalld.conf; then
    sed -i "s/^DefaultZone=.*/DefaultZone=drop/" /etc/firewalld/firewalld.conf
else
    echo "DefaultZone=drop" >> /etc/firewalld/firewalld.conf
fi

cat << EOF > /etc/firewalld/zones/drop.xml
<?xml version="1.0" encoding="utf-8"?>
<zone target="DROP">
  <short>Drop</short>
  <description>Unsolicited incoming network packets are dropped.</description>
</zone>
EOF

