#!/bin/bash
# platform = multi_platform_ubuntu

rm /usr/share/pam-configs/*pwquality

DEBIAN_FRONTEND=noninteractive pam-auth-update
