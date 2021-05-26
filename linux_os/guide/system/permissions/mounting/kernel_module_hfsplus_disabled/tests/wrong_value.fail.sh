#!/bin/bash

touch /etc/modprobe.d/hfsplus.conf
sed -i '/install hfsplus/d' /etc/modprobe.d/hfsplus.conf
