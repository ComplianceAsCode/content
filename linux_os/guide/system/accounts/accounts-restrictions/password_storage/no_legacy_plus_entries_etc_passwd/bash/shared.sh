# platform = multi_platform_all

if grep -q '^\+' /etc/passwd; then
# backup old file to /etc/passwd-
	cp /etc/passwd /etc/passwd-
	chmod 0644 /etc/passwd-
	sed -i '/^\+.*$/d' /etc/passwd
fi
