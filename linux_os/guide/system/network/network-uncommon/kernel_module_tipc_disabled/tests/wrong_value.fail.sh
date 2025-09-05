#!/bin/bash

touch /etc/modprobe.d/tipc.conf
sed -i '/install tipc/d' /etc/modprobe.d/tipc.conf
