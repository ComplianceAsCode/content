#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\nupgrade_type = security" > "$CONF"
