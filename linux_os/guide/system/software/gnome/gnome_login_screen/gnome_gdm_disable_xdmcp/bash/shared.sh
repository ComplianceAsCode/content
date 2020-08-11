# platform = multi_platform_all

CONF="/etc/gdm/custom.conf"
DISABL_XDMCP_REGEX="[[:space:]]*\[xdmcp]([^\n\[]*\n+)+?[[:space:]]*Enable"
XDMCP_REGEX="[[:space:]]*\[xdmcp]"

# This is a candidate of bash ini Jinja macro
# Try find [xdmcp] and Enable in custom.conf, if it exists, set
# to false, if it isn't here, add it, if [xdmcp] doesn't exist, add it there
if grep -qzosP "$DISABL_XDMCP_REGEX" $CONF; then
    sed -i "s/Enable[^(\n)]*/Enable=false/" $CONF
elif grep -qs "$XDMCP_REGEX" $CONF; then
    sed -i "/$XDMCP_REGEX/a Enable=false" $CONF
else
    mkdir -p /etc/gdm
    printf '%s\n' "[xdmcp]" "Enable=false" >> $CONF
fi
