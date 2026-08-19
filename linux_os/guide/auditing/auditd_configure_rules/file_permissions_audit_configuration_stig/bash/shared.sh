# platform = multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# Copied and modified from `file_permissions/bash.template` template

if rpm --quiet -q audit && rpm --quiet -q kernel-core; then

find /etc/audit/ -maxdepth 1 -type f \
    -regextype posix-extended -regex '^.*audit(\.rules|d\.conf)$' \
    -exec chmod 0600 {} \;

find /etc/audit/rules.d/ -maxdepth 1 -type f -name '*.rules' \
    -exec chmod 0600 {} \;

# augenrules --load hardcodes chmod 0640 on audit.rules on every rewrite of the rules.d files.
# Install ExecStartPost in auditd.service to restore 0600 after each run.
# Runs inside the auditd_t SELinux domain which has write access to auditd_etc_t files.
# On RHEL 8/9, augenrules is called via ExecStartPost in auditd.service directly.
mkdir -p /etc/systemd/system/auditd.service.d
chmod 0755 /etc/systemd/system/auditd.service.d

cat > /etc/systemd/system/auditd.service.d/permissions.conf << 'EOF'
[Service]
ExecStartPost=/usr/bin/chmod 0600 /etc/audit/audit.rules
EOF
chmod 0644 /etc/systemd/system/auditd.service.d/permissions.conf

systemctl daemon-reload

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi
