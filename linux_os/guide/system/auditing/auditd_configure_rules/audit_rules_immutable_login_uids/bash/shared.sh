# platform = multi_platform_all

# in case auditctl is used
if grep -q '^\s*ExecStartPost=-/sbin/auditctl' /usr/lib/systemd/system/auditd.service; then
  if ! grep -q '^\s*--loginuid-immutable\s*$' /etc/audit/audit.rules; then
    echo "--loginuid-immutable" >> /etc/audit/audit.rules
  fi
else
  immutable_found=0
  while IFS= read -r -d '' f; do
    if grep -q '^\s*--loginuid-immutable\s*$' "$f"; then
      immutable_found=1
    fi
  done <    <(find /etc/audit/rules.d -maxdepth 1 -name '*.rules' -print0)
  if [ $immutable_found -eq 0 ]; then
    echo "--loginuid-immutable" >> /etc/audit/rules.d/immutable.rules
  fi
fi

