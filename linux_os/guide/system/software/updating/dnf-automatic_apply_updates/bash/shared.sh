# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

CONF="/etc/dnf/automatic.conf"
APPLY_UPDATES_REGEX="[[:space:]]*\[commands]([^\n\[]*\n+)+?[[:space:]]*apply_updates"
COMMANDS_REGEX="[[:space:]]*\[commands]"

# Try find [commands] and apply_updates in automatic.conf, if it exists, set
# to yes, if it isn't here, add it, if [commands] doesn't exist, add it there
if grep -qzosP $APPLY_UPDATES_REGEX $CONF; then
    sed -i "s/apply_updates[^(\n)]*/apply_updates = yes/" $CONF
elif grep -qs $COMMANDS_REGEX $CONF; then
    sed -i "/$COMMANDS_REGEX/a apply_updates = yes" $CONF
else
    mkdir -p /etc/dnf
    echo -e "[commands]\napply_updates = yes" >> $CONF
fi
