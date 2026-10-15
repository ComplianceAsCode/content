# platform = multi_platform_almalinux
# reboot = false
# strategy = enable
# complexity = low
# disruption = low

repo_files=$(grep -l -E '^\[tuxcare-esu\]\s*$' /etc/yum.repos.d/*.repo 2>/dev/null || true)
if [ -n "$repo_files" ]; then
    for repo_file in $repo_files; do
        # Set enabled=1 inside the [tuxcare-esu] section only
        sed -i -E '/^\[tuxcare-esu\]\s*$/,/^\[/{s/^\s*enabled\s*=.*$/enabled=1/}' "$repo_file"
    done
else
    echo "The tuxcare-esu repository is not configured. Install tuxcare-release and register the ESU license key with tuxctl." >&2
fi
