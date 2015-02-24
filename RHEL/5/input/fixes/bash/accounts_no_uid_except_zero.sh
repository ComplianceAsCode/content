for UID0_USER in `cat /etc/passwd | cut -d: -f1,3 | grep :0$ | grep -v ^root: | cut -d: -f1`; do
	userdel -rf ${UID0_USER}
done
