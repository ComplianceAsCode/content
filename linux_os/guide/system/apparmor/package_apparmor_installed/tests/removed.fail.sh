#!/bin/bash

if command -v rpm; then
    rpm -e --nodeps apparmor
elif command -v apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get remove -y apparmor
fi
