#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\n#apply_updates = yes" > "$CONF"
