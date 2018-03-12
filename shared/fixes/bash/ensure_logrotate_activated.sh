# platform = multi_platform_rhel

# daily rotation is configured
grep -q "^daily$" /etc/logrotate.conf || echo "daily" >> /etc/logrotate.conf

# remove any line configuring weekly, monthly or yearly rotation
sed -i -r "/^(weekly|monthly|yearly)$/d" /etc/logrotate.conf
