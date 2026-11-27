#!/bin/bash
# platform = multi_platform_ubuntu

find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -ri 's#http://#https://#g' {} + 2>/dev/null || true
cat > /etc/apt/sources.list.d/cac-test.sources <<'EOF'
Enabled: no
Types: deb
URIs: http://example.invalid/first
Suites: resolute
Components: main

Types: deb
URIs: https://example.invalid/second
 http://example.invalid/third
Suites: resolute
Components: main
Enabled: no

Types: deb
URIs: https://example.invalid/http://path
Suites: resolute
Components: main
EOF
