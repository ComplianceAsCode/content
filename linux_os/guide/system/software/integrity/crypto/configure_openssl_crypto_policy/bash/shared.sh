# platform = multi_platform_all

OPENSSL_CRYPTO_POLICY_SECTION='[ crypto_policy ]'
OPENSSL_CRYPTO_POLICY_SECTION_REGEX='\[\s*crypto_policy\s*\]'
{{% if product in ["fedora", "ol9", "rhel9"] %}}
OPENSSL_CRYPTO_POLICY_INCLUSION='.include = /etc/crypto-policies/back-ends/opensslcnf.config'
{{% else %}}
OPENSSL_CRYPTO_POLICY_INCLUSION='.include /etc/crypto-policies/back-ends/opensslcnf.config'
{{%endif %}}
OPENSSL_CRYPTO_POLICY_INCLUSION_REGEX='^\s*\.include\s*(?:=\s*)?/etc/crypto-policies/back-ends/opensslcnf.config$'


{{% if 'sle' in product %}}
  {{% set openssl_cnf_path="/etc/ssl/openssl.cnf" %}}
{{% else %}}
  {{% set openssl_cnf_path="/etc/pki/tls/openssl.cnf" %}}
{{% endif %}}

function remediate_openssl_crypto_policy() {
	CONFIG_FILE={{{ openssl_cnf_path }}}
	if test -f "$CONFIG_FILE"; then
		if ! grep -q "^\\s*$OPENSSL_CRYPTO_POLICY_SECTION_REGEX" "$CONFIG_FILE"; then
			printf '\n%s\n\n%s' "$OPENSSL_CRYPTO_POLICY_SECTION" "$OPENSSL_CRYPTO_POLICY_INCLUSION" >> "$CONFIG_FILE"
			return 0
		elif ! grep -q "^\\s*$OPENSSL_CRYPTO_POLICY_INCLUSION_REGEX" "$CONFIG_FILE"; then
			sed -i "s|$OPENSSL_CRYPTO_POLICY_SECTION_REGEX|&\\n\\n$OPENSSL_CRYPTO_POLICY_INCLUSION\\n|" "$CONFIG_FILE"
			return 0
		fi
	else
		echo "Aborting remediation as '$CONFIG_FILE' was not even found." >&2
		return 1
	fi
}

remediate_openssl_crypto_policy
