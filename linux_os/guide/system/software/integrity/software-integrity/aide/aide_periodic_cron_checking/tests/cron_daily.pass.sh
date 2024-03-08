#!/bin/bash
# packages = aide,crontabs

mkdir -p /etc/cron.daily
echo "{{{ aide_bin_path }}} --check" > /etc/cron.daily/aide
