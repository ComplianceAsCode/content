#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

systemctl enable dailyaidecheck.service
systemctl disable dailyaidecheck.timer
if [[ $(systemctl is-system-running) != "offline" ]]; then
    systemctl stop dailyaidecheck.timer
fi
