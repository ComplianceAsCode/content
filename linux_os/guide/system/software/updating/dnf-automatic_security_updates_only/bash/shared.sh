# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

CONF="/etc/dnf/automatic.conf"
APPLY_UPDATES_REGEX="[[:space:]]*\[commands]([^\n\[]*\n+)+?[[:space:]]*upgrade_type"
COMMANDS_REGEX="[[:space:]]*\[commands]"

# Try find [commands] and upgrade_type in automatic.conf, if it exists, set
# it to security, if it isn't here, add it, if [commands] doesn't exist,
# add it there
if grep -qzosP $APPLY_UPDATES_REGEX $CONF; then
    sed -i "s/upgrade_type[^(\n)]*/upgrade_type = security/" $CONF
elif grep -qs $COMMANDS_REGEX $CONF; then
    sed -i "/$COMMANDS_REGEX/a upgrade_type = security" $CONF
else
    mkdir -p /etc/dnf
    echo -e "[commands]\nupgrade_type = security" >> $CONF
fi
