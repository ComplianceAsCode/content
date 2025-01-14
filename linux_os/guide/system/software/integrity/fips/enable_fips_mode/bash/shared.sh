# platform = multi_platform_all
{{{ bash_instantiate_variables("var_system_crypto_policy") }}}

if {{{ bash_bootc_build() }}}; then
	crypto_policies_no_reload="--no-reload"
	cat > /usr/lib/bootc/kargs.d/01-fips.toml << EOF
kargs = ["fips=1"]
EOF
else
	fips-mode-setup --enable
fi

stderr_of_call=$(update-crypto-policies $crypto_policies_no_reload --set ${var_system_crypto_policy} 2>&1 > /dev/null)
rc=$?

if test "$rc" = 127; then
	echo "$stderr_of_call" >&2
	echo "Make sure that the script is installed on the remediated system." >&2
	echo "See output of the 'dnf provides update-crypto-policies' command" >&2
	echo "to see what package to (re)install" >&2

	false  # end with an error code
elif test "$rc" != 0; then
	echo "Error invoking the update-crypto-policies script: $stderr_of_call" >&2
	false  # end with an error code
fi
