#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire { Check-Date "true"; };' > /etc/apt/apt.conf.d/99-repository.policy.conf
