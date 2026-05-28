# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# Remove any existing perm() directives to avoid duplicates
sed -i '/^\s*perm(/d' /etc/syslog-ng/syslog-ng.conf
find /etc/syslog-ng/conf.d/ -name "*.conf" -exec sed -i '/^\s*perm(/d' {} \;

# Add perm(0640) via a drop-in options block
echo 'options { perm(0640); };' > /etc/syslog-ng/conf.d/00-syslogng_filecreatemode.conf

systemctl restart syslog-ng.service
