#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# profiles = ospp, standard
# packages = crypto-policies-scripts

sed -i "1d" /etc/crypto-policies/config
