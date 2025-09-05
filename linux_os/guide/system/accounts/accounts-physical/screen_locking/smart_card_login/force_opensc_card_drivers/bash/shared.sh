# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_rhv,multi_platform_ol
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

. /usr/share/scap-security-guide/remediation_functions
populate var_smartcard_drivers

OPENSC_TOOL="/usr/bin/opensc-tool"

if [ -f "${OPENSC_TOOL}" ]; then
    ${OPENSC_TOOL} -S app:default:force_card_driver:$var_smartcard_drivers
fi
