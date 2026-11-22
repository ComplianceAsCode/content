#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire { AllowWeakRepositories "0"; };' > /etc/apt/apt.conf.d/99-repository.policy.conf
