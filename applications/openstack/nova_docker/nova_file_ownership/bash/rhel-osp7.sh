# platform = Red Hat Enterprise Linux 7
for file in /var/lib/config-data/puppet-generated/nova/etc/nova/nova.conf \
		/var/lib/config-data/puppet-generated/nova/etc/nova/api-paste.ini \
		/var/lib/config-data/puppet-generated/nova/etc/nova/policy.json \
		/var/lib/config-data/puppet-generated/nova/etc/nova/rootwrap.conf; do
	chown root $file
	chgrp nova $file
done
