cat > /etc/init/control-alt-delete.conf << EOF
#
# This task is run whenever the Control-Alt-Delete key combination is
# pressed.  Usually used to shut down the machine.

start on control-alt-delete

exec /usr/bin/logger -p security.info "Control-Alt-Delete pressed"
EOF
