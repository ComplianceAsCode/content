# platform = Red Hat Enterprise Linux 7
STR_IDENTITY_URI=$(openstack-config --get /etc/nova/nova.conf keystone_authtoken identity_uri)
NEW_IDENTITY_URI=${STR_IDENTITY_URI:0:4}s${STR_IDENTITY_URI:4:-1}
openstack-config --set /etc/nova/nova.conf keystone_authtoken identity_uri $NEW_IDENTITY_URI

STR_AUTH_URI=$(openstack-config --get /etc/nova/nova.conf keystone_authtoken auth_uri)
NEW_AUTH_URI=${STR_AUTH_URI:0:4}s${STR_AUTH_URI:4:-1}
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri $NEW_AUTH_URI
