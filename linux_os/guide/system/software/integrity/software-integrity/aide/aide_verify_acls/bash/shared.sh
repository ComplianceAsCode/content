# platform = multi_platform_all

{{{ bash_package_install("aide") }}}

aide_conf="/etc/aide.conf"

groups=$(LC_ALL=C grep "^[A-Z][A-Za-z_]*" $aide_conf | grep -v "^ALLXTRAHASHES" | cut -f1 -d '=' | tr -d ' ' | sort -u)

for group in $groups
do
	config=$(grep "^$group\s*=" $aide_conf | cut -f2 -d '=' | tr -d ' ')

	if ! [[ $config = *acl* ]]
	then
		if [[ -z $config ]]
		then
			config="acl"
		else
			config=$config"+acl"
		fi
	fi
	sed -i "s/^$group\s*=.*/$group = $config/g" $aide_conf
done
