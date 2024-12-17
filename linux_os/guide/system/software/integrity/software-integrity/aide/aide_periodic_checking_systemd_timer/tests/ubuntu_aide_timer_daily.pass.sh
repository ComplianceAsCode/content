# platform = multi_platform_ubuntu
# packages = aide

systemctl enable dailyaidecheck.service
systemctl --now enable dailyaidecheck.timer
