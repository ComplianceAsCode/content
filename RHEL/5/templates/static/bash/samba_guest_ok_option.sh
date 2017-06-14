# platform = Red Hat Enterprise Linux 5
sed -i '/^[#|;]/!s/\(guest ok =\).*/\1 no/g' /etc/samba/smb.conf