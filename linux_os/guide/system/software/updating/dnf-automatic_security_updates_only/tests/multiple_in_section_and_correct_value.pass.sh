#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\napply_updates = yes\nupgrade_type = security" > "$CONF"
