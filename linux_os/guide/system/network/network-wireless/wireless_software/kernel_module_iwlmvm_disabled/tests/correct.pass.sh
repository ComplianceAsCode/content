#!/bin/bash

mkdir -p /etc/modprobe.d/
echo "install iwlmvm /bin/true" > /etc/modprobe.d/iwlmvm.conf