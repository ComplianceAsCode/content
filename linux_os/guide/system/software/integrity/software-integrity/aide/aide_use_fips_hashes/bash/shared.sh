# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux,multi_platform_debian,multi_platform_ubuntu

{{{ bash_package_install("aide") }}}

aide_conf="{{{ aide_conf_path }}}"
forbidden_hashes=(sha1 rmd160 sha256 whirlpool tiger haval gost crc32)

groups=$(LC_ALL=C grep "^[A-Z][A-Za-z_]*" $aide_conf | cut -f1 -d ' ' | tr -d ' ' | sort -u)

for group in $groups
do
	config=$(grep "^$group\s*=" $aide_conf | cut -f2 -d '=' | tr -d ' ')

{{%- if 'debian' not in product and 'ubuntu' not in product %}}

	if ! [[ $config = *sha512* ]]
	then
		config=$config"+sha512"
	fi
{{%- endif %}}

	for hash in "${forbidden_hashes[@]}"
	do
		config=$(echo $config | sed "s/$hash//")
	done

	config=$(echo $config | sed "s/^\+*//")
	config=$(echo $config | sed "s/\+\++/+/")
	config=$(echo $config | sed "s/\+$//")

	sed -i "s/^$group\s*=.*/$group = $config/g" $aide_conf
done
{{%- if 'debian' in product or 'ubuntu' in product %}}

# Debian and Ubuntu hash files through the Checksums group; the other groups
# deliberately carry no hash, so only Checksums gets sha512.
{{{ bash_replace_or_append(aide_conf_path, '^Checksums', 'sha512', '%s = %s', cce_identifiers=cce_identifiers) }}}
{{%- endif %}}
