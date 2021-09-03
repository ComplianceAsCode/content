# platform = multi_platform_all

common_firewalld_ratelimit_args=(--direct --add-rule ipv4 filter INPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES)
if {{{ in_chrooted_environment }}}; then
    firewall-offline-cmd "${common_firewalld_ratelimit_args[@]}"
else
    firewall-cmd --permanent "${common_firewalld_ratelimit_args[@]}"
    firewall-cmd --reload
fi
