# platform = multi_platform_fedora,Red Hat OpenShift Container Platform 4,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4

if grep -q '^\+' /etc/passwd; then
# backup old file to /etc/passwd-
	cp /etc/passwd /etc/passwd-
	sed -i '/^\+.*$/d' /etc/passwd
fi
