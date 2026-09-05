#!/bin/bash
# platform = multi_platform_ubuntu

find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -ri 's#http://#https://#g' {} + 2>/dev/null || true
# A URIs line may carry several URIs; an http:// one after an https:// one still counts.
cat > /etc/apt/sources.list.d/cac-test.sources <<'EOF'
Types: deb
URIs: https://archive.ubuntu.com/ubuntu http://security.ubuntu.com/ubuntu
Suites: resolute
Components: main
EOF
