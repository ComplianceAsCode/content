# platform = Red Hat Enterprise Linux 7
for file in /var/lib/config-data/puppet-generated/cinder/etc/cinder/cinder.conf \
		/var/lib/config-data/puppet-generated/cinder/etc/cinder/api-paste.ini \
		/var/lib/config-data/puppet-generated/cinder/etc/cinder/policy.json \
		/var/lib/config-data/puppet-generated/cinder/etc/cinder/rootwrap.conf; do
	chown root $file
	chgrp cinder $file
done
