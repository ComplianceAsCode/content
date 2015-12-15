# platform = Red Hat Enterprise Linux 7
for file in /etc/nova/nova.conf \
		/etc/nova/api-paste.ini \
		/etc/nova/policy.json \
		/etc/nova/rootwrap.conf; do
	chown root $file
	chgrp nova $file
done
