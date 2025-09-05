# platform = Apple macOS 10.15
# reboot = false
# strategy = enable
# complexity = low
# disruption = low

/usr/bin/sed -i.bak '/^policy/ s/$/,ahlt/' /etc/security/audit_control; sudo /usr/sbin/audit -s
