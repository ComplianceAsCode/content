# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

# Get interactive users using getent to support remote users (LDAP, SSSD, etc.)
while IFS=: read -r _ _ uid gid _ home shell; do
    # Filter interactive users: UID >= {{{ uid_min }}}, not nobody, has valid home dir, not nologin/false shell
    if [ "$uid" -ge {{{ uid_min }}} ] && [ "$uid" -ne {{{ nobody_uid }}} ] && \
       [ "$home" != "/" ] && \
       [ "$shell" != "/sbin/nologin" ] && [ "$shell" != "/usr/sbin/nologin" ] && \
       [ "$shell" != "/bin/false" ] && [ "$shell" != "/usr/bin/false" ]; then
        # Arguments are properly quoted to prevent command injection
        chgrp -f -- "$gid" "$home"
    fi
done < <(getent passwd)
