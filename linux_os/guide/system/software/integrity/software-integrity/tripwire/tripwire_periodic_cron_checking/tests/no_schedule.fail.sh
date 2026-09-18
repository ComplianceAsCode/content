#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian
# remediation = none

# Neither /etc/cron.daily/tripwire nor /etc/cron.weekly/tripwire exists,
# so no periodic check is scheduled. Expected result: FAIL.
rm -f /etc/cron.daily/tripwire /etc/cron.weekly/tripwire
