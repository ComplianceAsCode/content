#!/bin/bash
{{% if product in [ 'opensuse16', 'sle16' ] %}}
# packages = gdm,displaymanager-sysconfig
{{% else %}}
# packages = gdm
{{% endif %}}

if (sed -n '/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/p' /etc/sysconfig/displaymanager)
then
  sed -i "s/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=.*/DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"yes\"/g" /etc/sysconfig/displaymanager
fi
