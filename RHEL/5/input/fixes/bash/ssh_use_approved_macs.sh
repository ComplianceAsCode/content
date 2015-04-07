if [ $(cat /etc/ssh/ssh_config | grep -c "^MACs") = "0" ]; then
	echo "MACs hmac-sha1" | tee -a /etc/ssh/ssh_config &>/dev/null
else
	sed -i 's/^MACs.*/MACs hmac-sha1/' /etc/ssh/ssh_config
fi
