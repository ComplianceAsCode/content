# platform = multi_platform_ubuntu
# packages = aide

systemctl mask dailyaidecheck.service
systemctl --now enable dailyaidecheck.timer
