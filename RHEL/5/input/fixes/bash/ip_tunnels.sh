ip tunnel list | cut -d: -f1 | while read TUNNEL_INTERFACE; do ip tunnel del $TUNNEL_INTERFACE 2>/dev/null; done
