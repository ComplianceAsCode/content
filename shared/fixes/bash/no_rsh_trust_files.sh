for homedir in `awk -F: '{ print $6 }' /etc/passwd`
do
	if [ -e $homedir ]; then
		rm -f $homedir/.rhosts
	fi
done

rm /etc/hosts.equiv
