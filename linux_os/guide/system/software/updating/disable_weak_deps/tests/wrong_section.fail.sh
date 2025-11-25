#!/bin/bash
cat <<EOF >/etc/dnf/dnf.conf
[notmain]
install_weak_deps = 0
EOF
