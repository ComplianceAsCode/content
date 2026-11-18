# platform = multi_platform_all

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
    GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
    if ! [ "$GROUP" == 'root' ] ; then
       MODE=0640
    else
       MODE=0600
    fi
else
    MODE=0600
fi

# The check covers the rotated logs too: audit.log.1 and up.
for f in "$FILE" "$FILE".*; do
    if [ -f "$f" ]; then
        chmod "$MODE" "$f"
    fi
done
