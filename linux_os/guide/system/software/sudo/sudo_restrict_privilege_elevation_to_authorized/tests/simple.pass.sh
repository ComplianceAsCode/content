#!/bin/bash
# packages = sudo

echo 'user ALL=(admin) ALL' > /etc/sudoers
echo 'user ALL=(admin:admin) ALL' > /etc/sudoers.d/foo
