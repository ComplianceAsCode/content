#!/bin/bash
# platform = multi_platform_debian
# remediation = none

# Remove pam_motd entries from every PAM file checked by this rule.
for f in /etc/pam.d/*; do
    [[ -f "$f" ]] && sed -ri '/pam_motd\.so/d' "$f"
done

# One referenced file exists with correct access, the other does not exist.
printf 'Authorized use only.\n' > /etc/motd.cac
chown root:root /etc/motd.cac
chmod 0644 /etc/motd.cac
rm -f /etc/motd.cac-missing
echo 'session optional pam_motd.so motd=/etc/motd.cac' >> /etc/pam.d/sshd
echo 'session optional pam_motd.so motd=/etc/motd.cac-missing' >> /etc/pam.d/login
