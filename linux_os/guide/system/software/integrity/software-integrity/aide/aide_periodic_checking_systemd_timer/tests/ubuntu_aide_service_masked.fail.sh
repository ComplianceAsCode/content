#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

systemctl mask dailyaidecheck.service
systemctl enable dailyaidecheck.timer
if [[ $(systemctl is-system-running) != "offline" ]]; then
    systemctl start dailyaidecheck.timer
fi
