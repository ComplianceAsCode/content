######################################################################
#By Luke "Brisk-OH" Brisk
#luke.brisk@boeing.com or luke.brisk@gmail.com
######################################################################

CLIENTSIGNING=$( grep -i 'client signing' /etc/samba/smb.conf | wc -l )

if [ $CLIENTSIGNING -eq 0 ];  then
	# Add to global section
	sed -i 's/\[global\]/\[global\]\n\n\tclient signing = mandatory/g' /etc/samba/smb.conf
else
	sed -i 's/[[:blank:]]*client[[:blank:]]signing[[:blank:]]*=[[:blank:]]*no/        client signing = mandatory/g' /etc/samba/smb.conf
fi

