# platform = multi_platform_all
{{{ bash_instantiate_variables("var_system_crypto_policy") }}}

if {{{ bash_bootc_build() }}}; then
	crypto_policies_no_reload="--no-reload"
	cat > /usr/lib/bootc/kargs.d/01-fips.toml << EOF
kargs = ["fips=1"]
EOF
