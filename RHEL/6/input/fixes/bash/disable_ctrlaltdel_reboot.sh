GREP_SHUTDOWN=$(grep '^\s*exec\s*/sbin/shutdown\s*-r\s*now.*$' /etc/init/control-alt-delete.override | wc -l)
# Remediate if the file contains /sbin/shutdown or if the override file does not exist
if [ "$GREP_SHUTDOWN" -ne 0 -o ! -e /etc/init/control-alt-delete.override ]; then
    echo 'exec /usr/bin/logger -p security.info "Ctrl-Alt-Delete pressed"' > /etc/init/control-alt-delete.override
fi
