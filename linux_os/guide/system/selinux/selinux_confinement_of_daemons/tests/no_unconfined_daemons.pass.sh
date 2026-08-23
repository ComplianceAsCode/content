#!/bin/bash

# sshd should be running and should have specific rules in SELinux policy
# so it should not be detected as unconfined_service_t.
systemctl status sshd.service
