#!/bin/bash
# packages = sudo

echo 'ALL ALL=(ALL) ALL' > /etc/sudoers
echo 'ALL ALL=(ALL:ALL) ALL' > /etc/sudoers.d/foo
