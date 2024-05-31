# platform = multi_platform_all

if LC_ALL=C grep -iw log_file /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
    chown root $FILE*
else
    chown root /var/log/audit/audit.log*
fi
