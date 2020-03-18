#!/bin/bash

yum -y install chrony

echo 'OPTIONS="-g -u chrony"' > /etc/sysconfig/chronyd
