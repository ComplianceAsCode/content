#!/bin/bash
# platform = multi_platform_ubuntu

find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -ri 's#http://#https://#g' {} + 2>/dev/null || true
cat > /etc/apt/sources.list.d/cac-test.sources <<'EOF'
Types: deb
URIs: https://example.invalid/first
# Alternate mirror
 http://example.invalid/second
Suites: resolute
Components: main
EOF
