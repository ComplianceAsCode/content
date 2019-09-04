#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\nupgrade_type = default" > "$CONF"
