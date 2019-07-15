#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\napply_updates = yes\nupgrade_type = security" > "$CONF"
