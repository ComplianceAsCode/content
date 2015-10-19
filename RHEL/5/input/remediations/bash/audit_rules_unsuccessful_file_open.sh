if [ -e /etc/audit/audit.rules ]; then
	if [ "`grep " -S open " /etc/audit/audit.rules | grep -v '#' | grep -c '\-F exit=-EACCES'`" = "0" ]; then
		if [ "`uname -p`" != "x86_64" ]; then
			echo "-a exit,always -F arch=b32 -S open -F exit=-EACCES -k access" >>/etc/audit/audit.rules
		else
			echo "-a exit,always -F arch=b64 -S open -F exit=-EACCES -k access" >>/etc/audit/audit.rules
		fi
	fi
	if [ "`grep " -S open " /etc/audit/audit.rules | grep -v '#' | grep -c '\-F exit=-EPERM'`" = "0" ]; then
		if [ "`uname -p`" != "x86_64" ]; then
			echo "-a exit,always -F arch=b32 -S open -F exit=-EPERM -k access" >>/etc/audit/audit.rules
		else
			echo "-a exit,always -F arch=b64 -S open -F exit=-EPERM -k access" >>/etc/audit/audit.rules
		fi
	fi
elif [ -e /etc/audit.rules ]; then
	if [ "`grep " -S open " /etc/audit.rules | grep -v '#' | grep -c '\success=0'`" = "0" ]; then
		if [ "`uname -p`" != "x86_64" ]; then
			echo "-a exit,always -F arch=b32 -S open -F success=0" >>/etc/audit.rules
		else
			echo "-a exit,always -F arch=b64 -S open -F success=0" >>/etc/audit.rules
		fi
	fi
else
	exit
fi
service auditd restart 1>/dev/null
