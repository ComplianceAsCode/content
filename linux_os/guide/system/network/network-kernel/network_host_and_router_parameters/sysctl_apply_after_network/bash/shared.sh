# platform = multi_platform_debian
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

DROPIN_DIR="/etc/systemd/system/systemd-sysctl.service.d"
DROPIN_FILE="${DROPIN_DIR}/cac_hardening.conf"

mkdir -p "${DROPIN_DIR}"

if ! grep -qrP "^After=.*network\.target" "${DROPIN_DIR}/" 2>/dev/null; then
    if grep -q "^\[Unit\]" "${DROPIN_FILE}" 2>/dev/null; then
        sed -i '/^\[Unit\]/a After=network.target' "${DROPIN_FILE}"
    else
        printf '[Unit]\nAfter=network.target\n' >> "${DROPIN_FILE}"
    fi
fi

systemctl daemon-reload
