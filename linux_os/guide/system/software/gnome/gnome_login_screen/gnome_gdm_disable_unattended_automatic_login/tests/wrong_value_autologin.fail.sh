#!/bin/bash
# packages = gdm

if (sed -n '/^DISPLAYMANAGER_AUTOLOGIN=\"\"/p' /etc/sysconfig/displaymanager)
then
  sed -i "s/^DISPLAYMANAGER_AUTOLOGIN=\"\"/DISPLAYMANAGER_AUTOLOGIN=\"USER\"/g" /etc/sysconfig/displaymanager
fi
