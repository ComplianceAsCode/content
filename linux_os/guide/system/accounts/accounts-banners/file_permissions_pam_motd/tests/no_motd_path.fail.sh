#!/bin/bash
# platform = multi_platform_debian
# remediation = none

# Remove pam_motd entries from every PAM file checked by this rule.
for f in /etc/pam.d/*; do
    [[ -f "$f" ]] && sed -ri '/pam_motd\.so/d' "$f"
done

echo 'session optional pam_motd.so noupdate' >> /etc/pam.d/sshd
