# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux
SECURITY_LIMITS_FILE="/etc/security/limits.conf"
DROPIN_DIR="/etc/security/limits.d"
DROPIN_FILE="$DROPIN_DIR/10-ssg-hardening.conf"
REGEX_CORRECT_VALUE="^\s*\*\s+hard\s+core\s+0\s*$"

# Remove bad configuration in drop-ins
if [ -d "$DROPIN_DIR" ]; then
    for override in "$DROPIN_DIR"/*.conf; do
        if [ -f "$override" ] && ! grep -qE "$REGEX_CORRECT_VALUE" "$override"; then
            sed -ir -E '/^[[:space:]]*\*[[:space:]]+hard[[:space:]]+core[[:space:]]+/ s/^/#/' "$override"
        fi
    done
fi

if [ -d "$DROPIN_DIR" ] && grep -qEr "$REGEX_CORRECT_VALUE" "$DROPIN_DIR"; then
    exit 0
elif [ ! -d "$DROPIN_DIR" ] && grep -qE "$REGEX_CORRECT_VALUE" "$SECURITY_LIMITS_FILE"; then
    exit 0
else
    mkdir -p "$DROPIN_DIR"
    echo "*     hard   core    0" >> $DROPIN_FILE
fi
