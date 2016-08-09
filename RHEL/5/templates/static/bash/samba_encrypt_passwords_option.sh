if [ "$(grep -c '^[ |\t]*encrypt passwords' /etc/samba/smb.conf)" = "0" ]; then
	sed -i 's/\(^\[global\]$\)/\1\n\n\tencrypt passwords = yes/' /etc/samba/smb.conf
else
	sed -i '/^[#|;]/!s/\(encrypt passwords =\).*/\1 yes/g' /etc/samba/smb.conf
fi
