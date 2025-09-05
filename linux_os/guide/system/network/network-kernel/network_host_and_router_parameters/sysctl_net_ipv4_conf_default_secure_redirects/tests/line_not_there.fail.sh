#!/bin/bash

sed -i "/^net.ipv4.conf.default.secure_redirects.*/d" /etc/sysctl.conf

sysctl -w net.ipv4.conf.default.secure_redirects=0
