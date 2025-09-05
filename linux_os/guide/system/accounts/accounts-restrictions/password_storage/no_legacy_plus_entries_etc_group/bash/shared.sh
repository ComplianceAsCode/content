# platform = multi_platform_all

if grep -q '^\+' /etc/group; then
# backup old file to /etc/group-
	cp /etc/group /etc/group-
	sed -i '/^\+.*$/d' /etc/group
fi
