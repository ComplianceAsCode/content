# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

found=false
for f in /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf; do
	if [ ! -e "$f" ]; then
		continue
	fi
	user=$( awk '/^\s*\[/{f=0} /^\s*\[sssd\]/{f=1} f{nu=gensub("^\\s*user\\s*=\\s*(\\S+).*","\\1",1); if($0!=nu){user=nu}} END{print user}' $f )
	if [ -n "$user" ] ; then
		if [ "$user" != sssd ] ; then
			sed -i 's/^\s*user\s*=.*/user = sssd/' $f
		fi
		found=true
	fi
done

if ! $found ; then
	SSSD_CONF="/etc/sssd/conf.d/ospp.conf"
	mkdir -p $( dirname $SSSD_CONF )
	touch $SSSD_CONF
	chown root:root $SSSD_CONF
	chmod 600 $SSSD_CONF
	echo -e "[sssd]\nuser = sssd" >> $SSSD_CONF
fi
