#!/bin/bash
# platform = Ubuntu 26.04

for f in /etc/pam.d/*; do
    [[ -f "$f" ]] && sed -ri '/pam_motd\.so/d' "$f"
done
printf 'Authorized use only.\n' > /etc/motd.cac
chown root:root /etc/motd.cac
chmod 0644 /etc/motd.cac
echo 'session optional pam_motd.so motd="/etc/motd.cac"' >> /etc/pam.d/sshd
