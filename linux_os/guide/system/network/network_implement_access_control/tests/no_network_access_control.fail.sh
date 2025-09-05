#!/bin/bash
# packages = firewalld
# remediation = none

systemctl stop firewalld
systemctl disable firewalld

truncate -s 0 /etc/hosts.{allow,deny}
