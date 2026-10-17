#!/bin/bash
# packages = tripwire,linux-base
# remediation = none

# No tripwire check is scheduled in /etc/cron.daily or /etc/cron.weekly.
# Removes both Debian's default filename (tripwire) and Fedora's
# (tripwire-check) so this is FAIL regardless of distribution.
# Expected result: FAIL.
rm -f /etc/cron.daily/tripwire /etc/cron.daily/tripwire-check \
      /etc/cron.weekly/tripwire /etc/cron.weekly/tripwire-check
