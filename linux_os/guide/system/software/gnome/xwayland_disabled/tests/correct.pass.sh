#!/usr/bin/env bash
# packages = gdm
cat <<EOF >/etc/gdm/custom.conf
# GDM configuration storage

[daemon]
WaylandEnable=false

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true

EOF
