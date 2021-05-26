#!/bin/bash

touch /etc/modprobe.d/freevxfs.conf
sed -i '/install freevxfs/d' /etc/modprobe.d/freevxfs.conf
