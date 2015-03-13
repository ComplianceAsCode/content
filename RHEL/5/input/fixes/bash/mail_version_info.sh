SENDMAIL_CONFIG=$(rpm -ql sendmail | grep sendmail.cf)
SENDMAIL_MAINCONF=$(rpm -ql sendmail | grep sendmail.mc)
if [ "$(rpm -q sendmail-cf &>/dev/null; echo $?)" = "0" ]; then
	if [ -e "${SENDMAIL_MAINCONF}" ]; then
		if [ "$(grep -c "^define(\`confSMTP_LOGIN_MSG" "${SENDMAIL_MAINCONF}")" = "0" ]; then
			sed -i "0,/^define/s/\(^define\)/define(\`confSMTP_LOGIN_MSG', \` Mail Server Ready ; $b')dnl\n\1/" "${SENDMAIL_MAINCONF}"
		elif [ "$(grep -c "^define(\`confSMTP_LOGIN_MSG', \` Mail Server Ready ; \$b')dnl" "${SENDMAIL_MAINCONF}")" = "0" ]; then
			sed -i "s/^define(\`confSMTP_LOGIN_MSG.*/define(\`confSMTP_LOGIN_MSG', \`Mail Server Ready ; \$b')dnl/" "${SENDMAIL_MAINCONF}"
		fi
		m4 "${SENDMAIL_MAINCONF}" > "${SENDMAIL_CONFIG}"
	fi
else
	sed -i 's/O SmtpGreetingMessage=.*/O SmtpGreetingMessage= Mail Server Ready ; $b/' "${SENDMAIL_CONFIG}"
fi
service sendmail restart 1>/dev/null
