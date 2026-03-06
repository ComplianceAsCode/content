# platform = multi_platform_all
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

# Ensure dnf-plugins-core is available for dnf config-manager
if ! command -v dnf &> /dev/null; then
    # System uses yum instead of dnf
    if command -v yum-config-manager &> /dev/null; then
        CONFIG_MANAGER="yum-config-manager"
    else
        echo "Neither dnf nor yum-config-manager found, cannot disable repositories" >&2
        exit 1
    fi
else
    # System uses dnf
    if ! command -v dnf config-manager &> /dev/null 2>&1; then
        dnf install -y dnf-plugins-core
    fi
    CONFIG_MANAGER="dnf config-manager"
fi

# Find all EPEL repository IDs by name pattern
for repo_file in /etc/yum.repos.d/*.repo; do
    [ -f "$repo_file" ] || continue

    # Extract repository IDs that contain "epel" (case-insensitive)
    while IFS= read -r repo_id; do
        $CONFIG_MANAGER --set-disabled "$repo_id"
    done < <(grep -ioP '^\[\K[^\]]*epel[^\]]*(?=\])' "$repo_file")
done
