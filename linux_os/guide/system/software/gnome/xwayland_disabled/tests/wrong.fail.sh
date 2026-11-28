#!/bin/bash
# packages = gdm
{{% set gdm_conf_path = '/etc/gdm3/daemon.conf' if 'debian' in product else '/etc/gdm3/custom.conf' if 'ubuntu' in product else '/etc/gdm/custom.conf' -%}}
cat <<EOF >{{{ gdm_conf_path }}}
# GDM configuration storage

[daemon]
# Uncomment the line below to force the login screen to use Xorg
WaylandEnable=true

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true

EOF
