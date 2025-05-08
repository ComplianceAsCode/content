#!/bin/bash
# packages = aide{{% if product != 'ubuntu2404' %}},crontabs{{% endif %}}

mkdir -p /etc/cron.daily
{{% if product == 'ubuntu2404' %}}
cat << 'EOF' > /etc/cron.daily/dailyaidecheck
#!/bin/sh

# Skip if systemd is running.
if [ -d /run/systemd/system ]; then
    exit 0
fi

SCRIPT="/usr/share/aide/bin/dailyaidecheck"
if [ -x "${SCRIPT}" ]; then
    if command -v capsh >/dev/null; then
        capsh --caps="cap_dac_read_search,cap_audit_write+eip cap_setpcap,cap_setuid,cap_setgid+ep" --keep=1 --user=_aide --addamb=cap_dac_read_search,cap_audit_write -- -c "${SCRIPT} --crondaily"
    else
        # no capsh present, run with full capabilities
        "${SCRIPT}" --crondaily
    fi
fi


EOF
{{% else %}}
echo "{{{ aide_bin_path }}} --check" > /etc/cron.daily/aide
{{% endif %}}
