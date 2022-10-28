#!/bin/bash
# packages = audispd-plugins

AUREMOTECONFIG={{{ audisp_conf_path }}}/plugins.d/au-remote.conf

truncate -s 0 $AUREMOTECONFIG

echo "\
active = yes
direction = out
path = /sbin/audisp-remote
type = always" >> $AUREMOTECONFIG
