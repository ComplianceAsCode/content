#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire { AllowInsecureRepositories "0"; };' > /etc/apt/apt.conf.d/99-repository.policy.conf
