#!/bin/bash
# packages = firewalld

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --new-zone=myzone
firewall-cmd \
    --permanent \
    --zone=myzone \
    --add-service="ssh" \
    --add-service="dhcp"

systemctl restart firewalld

firewall-cmd --set-default-zone=myzone
