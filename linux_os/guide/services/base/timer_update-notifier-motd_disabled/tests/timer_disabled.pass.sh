#!/bin/bash
# platform = Ubuntu 26.04
# packages = update-notifier-common

systemctl stop update-notifier-motd.timer 2>/dev/null || true
systemctl disable update-notifier-motd.timer 2>/dev/null || true
systemctl unmask update-notifier-motd.timer 2>/dev/null || true
