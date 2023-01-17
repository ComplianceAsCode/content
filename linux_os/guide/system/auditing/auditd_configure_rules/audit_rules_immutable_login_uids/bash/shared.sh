# platform = multi_platform_all

# in case auditctl is used
if grep -q '^\s*ExecStartPost=-/sbin/auditctl' /usr/lib/systemd/system/auditd.service; then
  if ! grep -q '^\s*--loginuid-immutable\s*$' /etc/audit/audit.rules; then
    echo "--loginuid-immutable" >> /etc/audit/audit.rules
  fi
else
  immutable_found=0
  for f in /etc/audit/rules.d/*.rules; do
    if grep -q '^\s*--loginuid-immutable\s*$' $f; then
  immutable_found=1
    fi
  done
  if [ $immutable_found -eq 0 ]; then
    echo "--loginuid-immutable" >> /etc/audit/rules.d/immutable.rules
  fi
fi

