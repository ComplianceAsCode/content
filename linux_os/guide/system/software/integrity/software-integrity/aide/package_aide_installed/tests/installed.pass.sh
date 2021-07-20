#!/bin/bash
# packages = aide

if command -v yum; then
    yum install -y aide
elif command -v apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y aide
fi
