# platform = multi_platform_fedora,Red Hat OpenShift Container Platform 4,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4

if grep -q '^\+' /etc/group; then
# backup old file to /etc/group-
	cp /etc/group /etc/group-
	sed -i '/^\+.*$/d' /etc/group
fi
