# platform = multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# Copied and modified from `file_permissions/bash.template` template
#
# Sets mode 0600 and ownership root:root on all audit config files.
# Installs an auditd.service dropin to restore 0600 on audit.rules after augenrules
# rewrites it to 0640 when /etc/audit/rules.d/ content changes (RHEL 8/9 only, not containers).

find /etc/audit/ -maxdepth 1 -type f \
    -regextype posix-extended -regex '^.*audit(\.rules|d\.conf)$' \
    -exec chmod 0600 {} \; \
    -exec chown root:root {} \;

find /etc/audit/rules.d/ -maxdepth 1 -type f -name '*.rules' \
    -exec chmod 0600 {} \; \
    -exec chown root:root {} \;

if rpm --quiet -q audit && rpm --quiet -q kernel-core; then

mkdir -p /etc/systemd/system/auditd.service.d
chmod 0755 /etc/systemd/system/auditd.service.d

cat > /etc/systemd/system/auditd.service.d/permissions.conf << 'EOF'
[Service]
ExecStartPost=/usr/bin/chmod 0600 /etc/audit/audit.rules
EOF
chmod 0644 /etc/systemd/system/auditd.service.d/permissions.conf
restorecon /etc/systemd/system/auditd.service.d/permissions.conf

systemctl daemon-reload
service restart auditd # IMPORTANT: this is necessary to ensure the dropin is loaded and the permissions for /etc/audit/ and /etc/audit/rules.d/ files are set correctly.

fi
