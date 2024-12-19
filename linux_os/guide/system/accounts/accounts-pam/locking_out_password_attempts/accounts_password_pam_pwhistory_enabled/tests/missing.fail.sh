#!/bin/bash
# platform = multi_platform_ubuntu

rm /usr/share/pam-configs/*pwhistory

DEBIAN_FRONTEND=noninteractive pam-auth-update
