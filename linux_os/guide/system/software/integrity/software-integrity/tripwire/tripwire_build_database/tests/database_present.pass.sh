#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

mkdir -p /var/lib/tripwire
touch "/var/lib/tripwire/$(hostname).twd"
