#!/bin/bash
cat <<EOF > /etc/dnf/dnf.conf
[main]
install_weak_deps = 0
EOF
