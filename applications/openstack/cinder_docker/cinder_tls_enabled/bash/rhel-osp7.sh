# platform = Red Hat Enterprise Linux 7
OLD_IDENTITY_URL=$(openstack-config --get /etc/cinder/cinder.conf keystone_authtoken identity_uri)
NEW_IDENTITY_URI="${OLD_IDENTITY_URI:0:4}s${OLD_IDENTITY_URI:4:-1}"
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken identity_uri $NEW_IDENTIY_URI

OLD_AUTH_URI=$(openstack-config --get /etc/cinder/cinder.conf keystone_authtoken auth_uri)
NEW_AUTH_URI="${OLD_AUTH_URI:0:4}s${OLD_AUTH_URI:4:-1}"
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_uri $NEW_AUTH_URI

