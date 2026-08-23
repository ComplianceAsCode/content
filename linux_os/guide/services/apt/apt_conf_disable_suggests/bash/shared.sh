# platform = multi_platform_debian

cat >> /etc/apt/apt.conf.d/60-no-weak-dependencies <<EOF
# disable installation of Suggests weak dependencies
APT::Install-Suggests "0";

EOF
