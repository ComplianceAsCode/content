#!/bin/bash

yum -y install chrony

echo 'OPTIONS=""' > /etc/sysconfig/chronyd
