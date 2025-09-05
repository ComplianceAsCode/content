#!/bin/bash

yum -y install chrony

echo 'OPTIONS="-u chrony"' > /etc/sysconfig/chronyd
