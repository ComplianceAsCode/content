# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
chmod 0755 /etc/apt/apt.conf.d
cat > /etc/apt/apt.conf.d/60-no-weak-dependencies <<'EOF'
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
chmod 0644 /etc/apt/apt.conf.d/60-no-weak-dependencies
