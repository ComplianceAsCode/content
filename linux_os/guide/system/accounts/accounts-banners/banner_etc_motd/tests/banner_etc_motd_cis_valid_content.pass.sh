#!/bin/bash
# profiles = cis, cis_server_l1, cis_workstation_l1, cis_workstation_l2

# CIS only requires the content matches the site policy, but doesn't accept exposure of OS technical information.
echo "CIS doesn't require a specific content, considering there is no technical information about the system." > /etc/motd
