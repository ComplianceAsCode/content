#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\n#upgrade_type = security" > "$CONF"
