#!/bin/bash
{{% if product in [ 'opensuse16', 'sle16' ] %}}
# packages = gdm,displaymanager-sysconfig
{{% else %}}
# packages = gdm
{{% endif %}}

autologin=$(sed -n '/^DISPLAYMANAGER_AUTOLOGIN=\"\"/p' /etc/sysconfig/displaymanager|wc -l)
passwordless=$(sed -n '/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/p' /etc/sysconfig/displaymanager|wc -l)

if [ $autologin -eq 0 ]; then sed -i "s/^DISPLAYMANAGER_AUTOLOGIN=.*/DISPLAYMANAGER_AUTOLOGIN=\"\"/g" /etc/sysconfig/displaymanager; fi

if [ $passwordless -eq 0 ]; then sed -i "s/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=.*/DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/g" /etc/sysconfig/displaymanager; fi
