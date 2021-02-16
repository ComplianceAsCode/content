# platform = multi_platform_sle

if [ -f "/usr/lib/systemd/system/auditd.service" ] ; then
    EXECSTARTPOST_SCRIPT=$(grep '^ExecStartPost=' /usr/lib/systemd/system/auditd.service | sed 's/ExecStartPost=//')

    if [[ "$EXECSTARTPOST_SCRIPT" == *"augenrules"* ]] ; then
        for f in /etc/audit/rules.d/*.rules ; do
            sed -E -i --follow-symlinks 's/^(\s*-a\s+task,never)/#\1/' "$f"
        done
    else
        # auditctl is used
        sed -E -i --follow-symlinks 's/^(\s*-a\s+task,never)/#\1/' /etc/audit/audit.rules
    fi

    systemctl is-active --quiet auditd.service
    if [ $? -ne 0 ] ; then
        systemctl restart auditd.service
    fi
fi
