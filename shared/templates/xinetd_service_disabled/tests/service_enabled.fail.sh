#!/bin/bash
# packages = xinetd,{{{ PACKAGENAME }}}

XINETD_SERVICE="/etc/xinetd.d/{{{ SERVICENAME }}}"
SERVICENAME="{{{ SERVICENAME }}}"

if [ -f "$XINETD_SERVICE" ]; then
    if grep -q 'disable' "$XINETD_SERVICE"; then
        sed -i "s/disable.*/disable = no/gI" "$XINETD_SERVICE"
    else
        sed -i "s/}/disable = no\n}/gI" "$XINETD_SERVICE"
    fi
else
cat > "$XINETD_SERVICE" << EOF
service $SERVICENAME
{
        disable         = no
}
EOF
fi
