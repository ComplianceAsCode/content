# platform = multi_platform_ubuntu

{{{ bash_package_install("aide") }}}

# AiDE usually adds its own cron jobs to /etc/cron.daily. If script is there, this rule is
# compliant. Otherwise, we copy the script to the /etc/cron.weekly
if ! egrep -q '^(\/usr\/bin\/)?aide(\.wrapper)?\s+' /etc/cron.*/*; then
    cp -f /usr/share/aide/config/cron.daily/aide /etc/cron.weekly/
fi
