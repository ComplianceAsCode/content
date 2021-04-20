#!/bin/bash
# platform = SUSE Linux Enterprise 15
# packages = sudo

echo 'ALL ALL=(ALL) ALL' > /etc/sudoers
echo 'ALL ALL=(ALL:ALL) ALL' > /etc/sudoers.d/foo
