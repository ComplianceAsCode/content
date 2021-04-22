# platform = multi_platform_ubuntu

{{{ bash_package_install("aide") }}}

# AiDE usually adds its own cron jobs to /etc/cron.daily. If script is there, this rule is
# compliant.
egrep -q '^(/usr/bin/)?aide\.wrapper\s+' /etc/cron.*/* && exit 0

ctab_line="0 5 * * * root /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"

if ! grep -q "$ctab_line" /etc/crontab; then
    echo -e "# Line added by CIS hardening scripts\n""$ctab_line" >> /etc/crontab
fi
