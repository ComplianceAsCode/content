# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_package_install("rsyslog") }}}

mkdir -p /etc/rsyslog.d /etc/systemd/journald.conf.d
printf '%s\n' 'authpriv.*    /var/log/sudo.log' > /etc/rsyslog.d/30-sudo.conf
# Ubuntu rsyslog drops privileges to syslog, so that account must own the file.
touch /var/log/sudo.log
chown syslog:adm /var/log/sudo.log
chmod 0640 /var/log/sudo.log

{{{ bash_ensure_ini_config(
    files="/etc/systemd/journald.conf.d/60-sudo-syslog.conf /etc/systemd/journald.conf.d/*.conf /etc/systemd/journald.conf",
    section="Journal", key="ForwardToSyslog", value="yes", no_quotes=true
) }}}
{{{ bash_ensure_ini_config(
    files="/etc/systemd/journald.conf.d/60-sudo-syslog.conf /etc/systemd/journald.conf.d/*.conf /etc/systemd/journald.conf",
    section="Journal", key="MaxLevelSyslog", value="debug", no_quotes=true
) }}}

rsyslogd -N1 || exit 1
systemctl restart systemd-journald.service
systemctl unmask rsyslog.service
systemctl enable --now rsyslog.service
systemctl restart rsyslog.service
