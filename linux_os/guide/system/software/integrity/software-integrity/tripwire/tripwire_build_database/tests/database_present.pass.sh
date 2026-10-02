#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

# A .twd database file is present, matching the DBFILE default documented
# in twconfig(4) (/var/lib/tripwire/$(HOSTNAME).twd). Expected result: PASS.
mkdir -p /var/lib/tripwire
touch "/var/lib/tripwire/$(hostname).twd"
