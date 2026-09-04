#!/bin/bash
# platform = multi_platform_ubuntu

# Create the journal directories (root-owned) but leave them empty so the
# recursive file ownership scan finds nothing to flag (PASS, not
# NOTAPPLICABLE).
mkdir -p /run/log/journal /var/log/journal
chown root /run/log/journal /var/log/journal
