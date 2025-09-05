#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

CONFIRM_SPAWN_YES="systemd.confirm_spawn=\(1\|yes\|true\|on\)"

sed -i "s/${CONFIRM_SPAWN_YES}//" /etc/default/grub
