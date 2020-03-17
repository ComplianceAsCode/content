#!/bin/bash

yum -y install chrony

rm -f /etc/sysconfig/ntpd
