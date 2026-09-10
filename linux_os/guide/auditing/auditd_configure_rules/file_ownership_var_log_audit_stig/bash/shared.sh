# platform = multi_platform_all

if LC_ALL=C grep -iqE '^[[:space:]]*log_file\b' /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^[[:space:]]*log_file[[:space:]]*=/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
fi

FILE=${FILE:-/var/log/audit/audit.log}
chown root "$(dirname "$FILE")"/*
