if [ -e /etc/dhclient.conf ]; then
	if [ $(grep -c "do-forward-updates false;" /etc/dhclient.conf) = 0 ]; then
		echo "do-forward-updates false;" | tee -a /etc/dhclient.conf &>/dev/null
	fi
else
	echo "do-forward-updates false;" | tee /etc/dhclient.conf &>/dev/null
fi
