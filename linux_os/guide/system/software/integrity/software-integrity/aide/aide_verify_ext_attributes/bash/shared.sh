# platform = multi_platform_all

{{{ bash_package_install("aide") }}}

aide_conf="{{{ aide_conf_path }}}"

{{% if "debian" in product %}}
groups=$(LC_ALL=C grep "^InodeData" $aide_conf | grep -v "^ALLXTRAHASHES" | cut -f1 -d '=' | tr -d ' ' | sort -u)
{{% else %}}
groups=$(LC_ALL=C grep "^[A-Z][A-Za-z_]*" $aide_conf | grep -v "^ALLXTRAHASHES" | cut -f1 -d '=' | tr -d ' ' | sort -u)
{{% endif %}}

for group in $groups
do
	config=$(grep "^$group\s*=" $aide_conf | cut -f2 -d '=' | tr -d ' ')

	if ! [[ $config = *xattrs* ]]
	then
		if [[ -z $config ]]
		then
			config="xattrs"
		else
			config=$config"+xattrs"
		fi
	fi
	sed -i "s/^$group\s*=.*/$group = $config/g" $aide_conf
done

# Add xattrs to selection lines that specify attributes directly (e.g., /path p+i+n+u+g)
LC_ALL=C sed -i -E '/^\/\S+\s+[a-z]/ { /xattrs/! s/^(\/\S+\s+)([a-z][a-zA-Z0-9+]*)/\1\2+xattrs/ }' "$aide_conf"
