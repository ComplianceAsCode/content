#!/bin/bash

yum -y install chrony

echo 'OPTIONS="-u root:root"' > /etc/sysconfig/chronyd
