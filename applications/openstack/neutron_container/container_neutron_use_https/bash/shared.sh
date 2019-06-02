# platform = Red Hat Enterprise Linux 7
STR_IDENTITY_URI=$(openstack-config --get /var/lib/config-data/puppet-generated/neutron/etc/neutron/neutron.conf keystone_authtoken identity_uri)
NEW_IDENTITY_URI=${STR_IDENTITY_URI:0:4}s${STR_IDENTITY_URI:4:-1}
openstack-config --set /var/lib/config-data/puppet-generated/neutron/etc/neutron/neutron.conf keystone_authtoken identity_uri $NEW_IDENTITY_URI

STR_AUTH_URI=$(openstack-config --get /var/lib/config-data/puppet-generated/neutron/etc/neutron/neutron.conf keystone_authtoken auth_uri)
NEW_AUTH_URI=${STR_AUTH_URI:0:4}s${STR_AUTH_URI:4:-1}
openstack-config --set /var/lib/config-data/puppet-generated/neutron/etc/neutron/neutron.conf keystone_authtoken auth_uri $NEW_AUTH_URI
