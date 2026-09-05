#!/bin/bash
# platform = multi_platform_ubuntu
# remediation = none

# Remove every pam_motd entry the check looks at, so each scenario starts clean.
for f in /etc/pam.d/sshd /etc/pam.d/login /etc/pam.d/su /etc/pam.d/gdm-password; do
    [ -f "$f" ] && sed -ri '/pam_motd\.so/d' "$f"
done

# pam_motd is used but no explicit motd= path is given.
echo 'session optional pam_motd.so noupdate' >> /etc/pam.d/sshd
