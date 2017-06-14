# platform = Red Hat Enterprise Linux 5
sed -i '/^[#|;]/!s/\([ |\t]*security =\).*/\1 user/' /etc/samba/smb.conf