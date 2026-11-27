# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux,multi_platform_debian
SECURITY_LIMITS_FILE="/etc/security/limits.conf"
DROPIN_DIR="/etc/security/limits.d"
DROPIN_FILE="$DROPIN_DIR/10-ssg-hardening.conf"
REGEX_CORRECT_VALUE="^\s*\*\s+hard\s+core\s+0\s*$"

# Remove bad configuration in drop-ins
if [ -d "$DROPIN_DIR" ]; then
    for override in "$DROPIN_DIR"/*.conf; do
        if [ -f "$override" ] && ! grep -qE "$REGEX_CORRECT_VALUE" "$override"; then
            sed -i -E '/^[[:space:]]*\*[[:space:]]+hard[[:space:]]+core[[:space:]]+/ s/^/#/' "$override"
        fi
    done
fi

# This code runs inside the profile remediation script, so it must not exit:
# that would skip the remediation of every rule after this one.
if [ -d "$DROPIN_DIR" ] && grep -qEr "$REGEX_CORRECT_VALUE" "$DROPIN_DIR"; then
    :  # already configured in a drop-in file
elif [ ! -d "$DROPIN_DIR" ] && grep -qE "$REGEX_CORRECT_VALUE" "$SECURITY_LIMITS_FILE"; then
    :  # already configured in limits.conf
else
    mkdir -p "$DROPIN_DIR"
    chmod 0755 "$DROPIN_DIR"
    echo "*     hard   core    0" >> $DROPIN_FILE
    chmod 0644 "$DROPIN_FILE"
fi
