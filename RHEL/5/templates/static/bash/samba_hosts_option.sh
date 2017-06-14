# platform = Red Hat Enterprise Linux 5
sed -i 's/\(^\[global\]$\)/\1\n\n\thosts allow = 127./' /etc/samba/smb.conf