# platform = Red Hat Enterprise Linux 7
openstack-config --set /etc/nova/nova.conf DEFAULT glance_api_insecure False
openstack-config --set /etc/nova/nova.conf glance api_insecure False
