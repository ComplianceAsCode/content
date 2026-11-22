#!/bin/bash
# platform = multi_platform_ubuntu

find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -ri 's#http://#https://#g' {} + 2>/dev/null || true
cat > /etc/apt/sources.list.d/cac-test.sources <<'EOF'
Types: deb
URIs: http://example.invalid/spaced
Suites: resolute
Components: main
Enabled : no

Enabled: -0X00
Types: deb
URIs: http://example.invalid/hex
Suites: resolute
Components: main
EOF
