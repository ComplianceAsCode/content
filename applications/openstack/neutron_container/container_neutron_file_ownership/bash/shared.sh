# platform = Red Hat Enterprise Linux 7
for file in /var/lib/config-data/puppet-generated/neutron/etc/neutron/neutron.conf \
		/var/lib/config-data/puppet-generated/neutron/etc/neutron/api-paste.ini \
		/var/lib/config-data/puppet-generated/neutron/etc/neutron/policy.json \
		/var/lib/config-data/puppet-generated/neutron/etc/neutron/rootwrap.conf; do
	chown root $file
	chgrp neutron $file
done
