#!/bin/bash


CONF="/etc/dnf/automatic.conf"
echo -e "[base]\napply_updates = yes" > "$CONF"
