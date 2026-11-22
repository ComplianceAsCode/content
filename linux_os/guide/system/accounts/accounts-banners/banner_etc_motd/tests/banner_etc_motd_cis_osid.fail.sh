#!/bin/bash
# profiles = cis, cis_server_l1, cis_workstation_l1, cis_workstation_l2

# CIS doesn't have an explicit content required, but doesn't expect OS IDs, like rhel.
echo "This system is rhel." > /etc/motd
