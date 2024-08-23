# platform = multi_platform_sle,multi_platform_slmicro

if ! (sed -n '/^DISPLAYMANAGER_AUTOLOGIN=\"\"/p' /etc/sysconfig/displaymanager)
then
  sed -i "s/^DISPLAYMANAGER_AUTOLOGIN=.*/DISPLAYMANAGER_AUTOLOGIN=\"\"/g" /etc/sysconfig/displaymanager
fi

if ! (sed -n '/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/p' /etc/sysconfig/displaymanager)
then
  sed -i "s/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=.*/DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/g" /etc/sysconfig/displaymanager
fi
