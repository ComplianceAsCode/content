# platform = Red Hat Enterprise Linux 7
for file in /etc/cinder/cinder.conf \
		/etc/cinder/api-paste.ini \
		/etc/cinder/policy.json \
		/etc/cinder/rootwrap.conf; do
	chown root $file
	chgrp cinder $file
done
