#!/bin/bash
# platform = Red Hat Enterprise Linux 9

# Reuse the existing mail account so remediation can change its shell after the scan.
usermod --shell /bin/bash mail
sed -i -E '/^mail:/s/^[^:]*:[^:]*:[0-9]+/mail:x:999/' /etc/passwd
