#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\nupgrade_type = default" > "$CONF"
