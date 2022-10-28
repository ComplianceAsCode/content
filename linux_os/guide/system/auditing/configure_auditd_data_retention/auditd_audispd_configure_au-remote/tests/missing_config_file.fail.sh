#!/bin/bash
# packages = audispd-plugins
# remediation = none

AUREMOTECONFIG={{{ audisp_conf_path }}}/plugins.d/au-remote.conf

rm -f "$AUREMOTECONFIG"
