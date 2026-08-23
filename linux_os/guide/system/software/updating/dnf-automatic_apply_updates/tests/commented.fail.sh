#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\n#apply_updates = yes" > "$CONF"
