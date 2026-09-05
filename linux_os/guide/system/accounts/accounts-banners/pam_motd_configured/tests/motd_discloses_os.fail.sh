#!/bin/bash
# platform = multi_platform_ubuntu
# remediation = none

# Remove every pam_motd entry the check looks at, so each scenario starts clean.
for f in /etc/pam.d/sshd /etc/pam.d/login /etc/pam.d/su /etc/pam.d/gdm-password; do
    [ -f "$f" ] && sed -ri '/pam_motd\.so/d' "$f"
done

printf 'Welcome to Ubuntu\n' > /etc/motd.cac
chmod 0644 /etc/motd.cac
echo 'session optional pam_motd.so motd=/etc/motd.cac' >> /etc/pam.d/sshd
