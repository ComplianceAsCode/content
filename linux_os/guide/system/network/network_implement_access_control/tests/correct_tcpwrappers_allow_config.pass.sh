#!/bin/bash
# packages = firewalld

systemctl stop firewalld
systemctl disable firewalld

echo "192.168.122.25" >> /etc/hosts.allow
