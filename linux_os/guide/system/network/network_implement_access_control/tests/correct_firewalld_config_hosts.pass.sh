#!/bin/bash
# packages = firewalld

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --set-default-zone=public

firewall-cmd --permanent \
    --zone=public \
    --add-source="192.168.122.25" \
    --add-source="192.168.122.28"

