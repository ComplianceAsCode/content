#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[commands]\napply_updates = yes" > "$CONF"
