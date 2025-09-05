# packages = ufw
# remediation = none

systemctl enable --now ufw
ufw allow ssh
ufw -f enable || exit 1
ufw disable
