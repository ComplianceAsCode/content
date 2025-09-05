#!/bin/bash

touch /etc/modprobe.d/cramfs.conf
sed -i '/install cramfs/d' /etc/modprobe.d/cramfs.conf
