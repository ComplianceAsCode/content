#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian
# remediation = none

# No .twd database file exists yet, so the Tripwire database hasn't been
# initialized. Expected result: FAIL.
mkdir -p /var/lib/tripwire
rm -f /var/lib/tripwire/*.twd
