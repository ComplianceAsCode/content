#!/bin/bash

yum -y remove xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-server-utils xorg-x11-server-Xwayland

systemctl set-default multi-user.target
