#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

systemctl enable dailyaidecheck.service
systemctl enable dailyaidecheck.timer
if [[ $(systemctl is-system-running) != "offline" ]]; then
    systemctl start dailyaidecheck.timer
fi
