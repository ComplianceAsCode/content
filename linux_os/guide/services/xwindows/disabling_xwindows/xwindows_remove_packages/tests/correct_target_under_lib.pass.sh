#!/bin/bash

yum -y remove xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-server-utils xorg-x11-server-Xwayland

ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
