# platform = multi_platform_sle,multi_platform_slmicro

if ! grep -q '^DISPLAYMANAGER_AUTOLOGIN=""' /etc/sysconfig/displaymanager; then
  sed -i "s/^DISPLAYMANAGER_AUTOLOGIN=.*/DISPLAYMANAGER_AUTOLOGIN=\"\"/g" /etc/sysconfig/displaymanager
fi

if ! grep -q '^DISPLAYMANAGER_PASSWORD_LESS_LOGIN="no"' /etc/sysconfig/displaymanager; then
  sed -i "s/^DISPLAYMANAGER_PASSWORD_LESS_LOGIN=.*/DISPLAYMANAGER_PASSWORD_LESS_LOGIN=\"no\"/g" /etc/sysconfig/displaymanager
fi
