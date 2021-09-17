#!/bin/bash

if command -v yum; then
    yum install -y apparmor
elif command -v apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y apparmor
fi
