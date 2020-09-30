#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[base]\nupgrade_type = security" > "$CONF"
