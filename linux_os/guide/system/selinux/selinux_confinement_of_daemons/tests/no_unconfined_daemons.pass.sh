#!/bin/bash

# sshd should be running and should have specific rules in SELinux policy
# so it should not be detected as unconfined_service_t.
systemctl start sshd.service 2>/dev/null || true

# Exit cleanly - the OVAL check should find no unconfined_service_t processes
exit 0
