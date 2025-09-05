# platform = multi_platform_all

if {{{ bash_bootc_build() }}}; then
	cat > /usr/lib/bootc/kargs.d/01-fips.toml << EOF
kargs = ["fips=1"]
EOF
fi
