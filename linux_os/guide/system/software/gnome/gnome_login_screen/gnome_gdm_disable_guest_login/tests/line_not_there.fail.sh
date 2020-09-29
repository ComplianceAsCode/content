#!/bin/bash

yum -y install gdm

sed -i "/^TimedLoginEnable=.*/d" /etc/gdm/custom.conf
