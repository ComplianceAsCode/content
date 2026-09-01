# platform = multi_platform_debian

cat >> /etc/apt/apt.conf.d/60-no-weak-dependencies <<EOF
# disable installation of Recommends weak dependencies
APT::Install-Recommends "0";

EOF
