for USHELL in `cut -d: -f7 /etc/passwd | egrep -v '(/usr/bin/false|/bin/false|/dev/null|/sbin/nologin|/bin/sync|/sbin/halt|/sbin/shutdown)' | uniq`; do
	if [ "$(grep -c "${USHELL}" /etc/shells)" = "0" ]; then
		echo "${USHELL}" >> /etc/shells
	fi
done
