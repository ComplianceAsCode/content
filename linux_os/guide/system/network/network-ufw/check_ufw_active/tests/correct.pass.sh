# packages = ufw

systemctl enable --now ufw
ufw allow ssh
ufw -f enable
