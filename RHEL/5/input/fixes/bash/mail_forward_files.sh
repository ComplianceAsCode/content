SENDMAIL_CONFIG=$(rpm -ql sendmail | grep sendmail.cf)
SENDMAIL_MAINCONF=$(rpm -ql sendmail | grep sendmail.mc)
if [ "$(rpm -q sendmail-cf &>/dev/null; echo $?)" = "0" ]; then
	if [ -e "${SENDMAIL_MAINCONF}" ]; then
		if [ "$(grep -c 'confFORWARD_PATH' "${SENDMAIL_MAINCONF}")" = "0" ]; then
			sed -i "0,/^define/s/\(^define\)/define(\`confFORWARD_PATH',\`')dnl\n\1/" "${SENDMAIL_MAINCONF}"
		elif [ "$(grep -c "define(\`confFORWARD_PATH',\`')dnl" "${SENDMAIL_MAINCONF}")" = "0" ]; then
			sed -i "s/define(\`confFORWARD.*/define(\`confFORWARD_PATH',\`')dnl/" "${SENDMAIL_MAINCONF}"
		fi
		m4 "${SENDMAIL_MAINCONF}" > "${SENDMAIL_CONFIG}"
	fi
else
	sed -i 's/O ForwardPath.*/O ForwardPath/' "${SENDMAIL_CONFIG}"
fi
service sendmail restart 1>/dev/null
for FILE in $(find /etc -name .forward -type f 2>/dev/null); do
	rm -f ${FILE}
done
