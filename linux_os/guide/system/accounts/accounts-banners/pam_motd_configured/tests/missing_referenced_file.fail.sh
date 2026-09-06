#!/bin/bash
# platform = multi_platform_ubuntu

for f in /etc/pam.d/sshd /etc/pam.d/login /etc/pam.d/su /etc/pam.d/gdm-password; do
    [ -f "$f" ] && sed -ri '/pam_motd\.so/d' "$f"
done

rm -f /run/motd.dynamic
printf '%s\n' \
    'session optional pam_motd.so motd=/run/motd.dynamic' \
    'session optional pam_motd.so noupdate' \
    >> /etc/pam.d/login
