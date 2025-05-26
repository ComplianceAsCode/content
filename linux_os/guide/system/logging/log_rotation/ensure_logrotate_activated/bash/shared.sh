# platform = multi_platform_all

LOGROTATE_CONF_FILE="/etc/logrotate.conf"
{{% if 'sle' in product or product == 'slmicro5' %}}
SYSTEMCTL_EXEC='/usr/bin/systemctl'
{{% else %}}
{{{ bash_package_install("crontabs") }}}
CRON_DAILY_LOGROTATE_FILE="/etc/cron.daily/logrotate"
{{% endif %}}

# daily rotation is configured
grep -q "^daily$" $LOGROTATE_CONF_FILE|| echo "daily" >> $LOGROTATE_CONF_FILE

# remove any line configuring weekly, monthly or yearly rotation
sed -i '/^\s*\(weekly\|monthly\|yearly\).*$/d' $LOGROTATE_CONF_FILE

{{% if 'sle' in product or product == 'slmicro5' %}}
# enable logrotate timer service
"$SYSTEMCTL_EXEC" unmask 'logrotate.timer'
if [[ $("$SYSTEMCTL_EXEC" is-system-running) != "offline" ]]; then
  "$SYSTEMCTL_EXEC" start 'logrotate.timer'
fi
"$SYSTEMCTL_EXEC" enable 'logrotate.timer'
{{% else %}}
# configure cron.daily if not already
if ! grep -q "^[[:space:]]*/usr/sbin/logrotate[[:alnum:][:blank:][:punct:]]*$LOGROTATE_CONF_FILE$" $CRON_DAILY_LOGROTATE_FILE; then
	echo '#!/bin/sh' > $CRON_DAILY_LOGROTATE_FILE
	echo "/usr/sbin/logrotate $LOGROTATE_CONF_FILE" >> $CRON_DAILY_LOGROTATE_FILE
fi
{{% endif %}}
