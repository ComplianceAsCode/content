#!/bin/bash
# platform = multi_platform_debian

# Remove pam_motd entries from every PAM file checked by this rule.
for f in /etc/pam.d/*; do
    [[ -f "$f" ]] && sed -ri '/pam_motd\.so/d' "$f"
done

# Debian default: sshd and login display /run/motd.dynamic.
printf 'Authorized use only.\n' > /run/motd.dynamic
chown root:root /run/motd.dynamic
chmod 0644 /run/motd.dynamic
for f in /etc/pam.d/sshd /etc/pam.d/login; do
    printf '%s\n' 'session optional pam_motd.so motd=/run/motd.dynamic' 'session optional pam_motd.so noupdate' >> "$f"
done
