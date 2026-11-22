#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = ospp, standard
# packages = crypto-policies-scripts

sed -i "1s/.*/LEGACY/" /etc/crypto-policies/config
