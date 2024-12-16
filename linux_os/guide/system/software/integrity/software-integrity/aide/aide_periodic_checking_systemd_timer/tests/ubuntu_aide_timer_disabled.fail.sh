# platform = multi_platform_ubuntu
# packages = aide

systemctl enable dailyaidecheck.service
systemctl --now disable dailyaidecheck.timer
