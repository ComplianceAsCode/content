#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_stig

sed -i "/^Ciphers.*/d" /etc/ssh/sshd_config
