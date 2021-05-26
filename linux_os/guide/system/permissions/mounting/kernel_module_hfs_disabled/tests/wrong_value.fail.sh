#!/bin/bash

touch /etc/modprobe.d/hfs.conf
sed -i '/install hfs/d' /etc/modprobe.d/hfs.conf
