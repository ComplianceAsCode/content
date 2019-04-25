# platform = Red Hat Enterprise Linux 7
for file in /etc/neutron/neutron.conf \
		/etc/neutron/api-paste.ini \
		/etc/neutron/policy.json \
		/etc/neutron/rootwrap.conf; do
	chown root $file
	chgrp neutron $file
done
