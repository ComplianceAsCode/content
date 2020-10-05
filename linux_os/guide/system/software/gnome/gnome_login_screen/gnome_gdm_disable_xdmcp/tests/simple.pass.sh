# packages = gdm

mkdir -p /etc/gdm
printf '%s\n' "# comment" "[xdmcp]" "# Enable=true" "Enable=false" > /etc/gdm/custom.conf
