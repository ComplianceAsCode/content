#!/bin/bash
{{% if product in [ 'opensuse16', 'sle16' ] %}}
# packages = gdm,displaymanager-sysconfig
{{% else %}}
# packages = gdm
{{% endif %}}

if (sed -n '/^DISPLAYMANAGER_AUTOLOGIN=\"\"/p' /etc/sysconfig/displaymanager)
then
  sed -i "s/^DISPLAYMANAGER_AUTOLOGIN=\"\"/DISPLAYMANAGER_AUTOLOGIN=\"USER\"/g" /etc/sysconfig/displaymanager
fi
