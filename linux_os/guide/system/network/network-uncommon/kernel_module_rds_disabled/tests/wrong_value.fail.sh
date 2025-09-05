#!/bin/bash

touch /etc/modprobe.d/rds.conf
sed -i '/install rds/d' /etc/modprobe.d/rds.conf
