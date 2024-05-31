# platform = multi_platform_ubuntu

# configure two dconf profiles:
# - gdm: required for banner/user_list settings
# - use': required for screenlock,automount,ctrlaltdel,... settings
gdm_profile_path=/etc/dconf/profile/gdm
user_profile_path=/etc/dconf/profile/user

mkdir -p /etc/dconf/profile
[[ -e "$gdm_profile_path" ]] || echo > "$gdm_profile_path"
[[ -e "$user_profile_path" ]] || echo > "$user_profile_path"

if ! grep -Pzq "(?s)^\s*user-db:user.*\n\s*system-db:gdm" "$gdm_profile_path"; then
    sed -i --follow-symlinks "1s/^/user-db:user\nsystem-db:gdm\n/" "$gdm_profile_path"
fi
if ! grep -Pzq "(?s)^\s*user-db:user.*\n\s*system-db:local" "$user_profile_path"; then
    sed -i --follow-symlinks "1s/^/user-db:user\nsystem-db:local\n/" "$user_profile_path"
fi
