#!/bin/bash

# mock `ss -tulnH`

cat > /usr/local/bin/ss <<EOF
cat <<FOE
udp UNCONN 0      0      127.0.0.53%lo:53    0.0.0.0:*
udp UNCONN 0      0            0.0.0.0:631   0.0.0.0:*
tcp LISTEN 0      4096   127.0.0.53%lo:53    0.0.0.0:*
tcp LISTEN 0      128        127.0.0.1:631   0.0.0.0:*
tcp LISTEN 0      128          0.0.0.0:22    0.0.0.0:*
tcp LISTEN 0      128            [::1]:631      [::]:*
tcp LISTEN 0      128             [::]:22       [::]:*
FOE
EOF
chmod +x /usr/local/bin/ss

ufw disable
ufw -f reset
