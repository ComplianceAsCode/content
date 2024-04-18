#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/rules.d/privileged.rules

# Create some files simulating dracut temporary files. See:
# - https://github.com/ComplianceAsCode/content/issues/10938
# - https://bugzilla.redhat.com/show_bug.cgi?id=1852337
# - https://bugzilla.redhat.com/show_bug.cgi?id=2230306
mount -o remount,suid,exec /var/tmp/
for file in mount umount; do
    path="/var/tmp/dracut.ksbFYD/initramfs/usr/bin"
    filepath="$path/$file"
    mkdir -p $path
    touch $filepath
    chmod 4755 $filepath
done
