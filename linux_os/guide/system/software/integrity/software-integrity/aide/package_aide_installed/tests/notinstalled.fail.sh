#!/bin/bash

if command -v yum; then
    yum remove -y aide
elif command -v apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get remove -y aide
fi
