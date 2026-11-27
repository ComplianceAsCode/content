#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# remediation = none

. $SHARED/grub2.sh

mkdir -p "$GRUB_CFG_ROOT"
cat << EOF > "$GRUB_CFG_ROOT/user.cfg"
GRUB2_PASSWORD=grub.pbkdf2.sha256.invalid
EOF
