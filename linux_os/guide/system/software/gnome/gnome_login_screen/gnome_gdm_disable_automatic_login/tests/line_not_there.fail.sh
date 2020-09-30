#!/bin/bash

yum -y install gdm

sed -i "/^AutomaticLoginEnable=.*/d" /etc/gdm/custom.conf
