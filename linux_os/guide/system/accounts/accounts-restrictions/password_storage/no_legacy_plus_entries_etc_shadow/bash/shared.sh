# platform = multi_platform_all

if grep -q '^\+' /etc/shadow; then
# backup old file to /etc/shadow-
	cp /etc/shadow /etc/shadow-
	sed -i '/^\+.*$/d' /etc/shadow
fi
