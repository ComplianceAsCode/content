#!/bin/bash
# platform = multi_platform_ubuntu

# Remove pam_motd entries from every PAM file checked by this rule.
for f in /etc/pam.d/sshd /etc/pam.d/login /etc/pam.d/su /etc/pam.d/gdm-password; do
    [ -f "$f" ] && sed -ri '/pam_motd\.so/d' "$f"
done

# Configure pam_motd without the required explicit motd= path.
echo 'session optional pam_motd.so noupdate' >> /etc/pam.d/sshd
