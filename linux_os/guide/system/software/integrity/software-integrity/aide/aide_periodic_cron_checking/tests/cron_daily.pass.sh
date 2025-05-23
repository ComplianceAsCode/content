#!/bin/bash
# packages = aide,crontabs

mkdir -p /etc/cron.daily
{{% if product == 'ubuntu2404' %}}
echo 'SCRIPT="/usr/share/aide/bin/dailyaidecheck"' > /etc/cron.daily/dailyaidecheck
{{% else %}}
echo "{{{ aide_bin_path }}} --check" > /etc/cron.daily/aide
{{% endif %}}
