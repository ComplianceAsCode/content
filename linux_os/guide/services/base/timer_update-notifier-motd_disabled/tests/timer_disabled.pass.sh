#!/bin/bash
# platform = multi_platform_ubuntu
# packages = update-notifier-common

systemctl stop update-notifier-motd.timer 2>/dev/null || true
systemctl disable update-notifier-motd.timer 2>/dev/null || true
systemctl unmask update-notifier-motd.timer 2>/dev/null || true
