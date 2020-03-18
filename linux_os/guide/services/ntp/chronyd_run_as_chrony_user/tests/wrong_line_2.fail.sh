#!/bin/bash

yum -y install chrony

echo 'OPTIONS="-g"' > /etc/sysconfig/chronyd
