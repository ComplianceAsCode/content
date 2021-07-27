# platform = multi_platform_all

if grep -q '^\+' /etc/passwd; then
# backup old file to /etc/passwd-
	cp /etc/passwd /etc/passwd-
	sed -i '/^\+.*$/d' /etc/passwd
fi
