# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
JOURNALD_REMEDY_CFG="/etc/systemd/journald.d/oscap-remedy.conf"
JOURNALD_CONFIG=$(ls /etc/systemd/journald.d/*.conf)
JOURNALD_CONFIG+=("/etc/systemd/journald.conf")
for f in "${JOURNALD_CONFIG[@]}"
do
    sed -i "/^\s*Compress\s*=\s*/d" "$f"
    # make sure file has newline at the end
    sed -i -e '$a\' "$f"
done
sed -i -e '$a\' "/etc/systemd/journald.conf"

cp "${JOURNALD_REMEDY_CFG}" "${JOURNALD_REMEDY_CFG}.bak"
# Insert before the line matching the regex '^#\s*Compress'.
line_number="$(LC_ALL=C grep -n "^#\s*Compress" "${JOURNALD_REMEDY_CFG}.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^#\s*Compress', insert at
    # the end of the file.
    printf '%s\n' "Compress='yes'" >> "${JOURNALD_REMEDY_CFG}"
else
    head -n "$(( line_number - 1 ))" "${JOURNALD_REMEDY_CFG}.bak" > "${JOURNALD_REMEDY_CFG}"
    printf '%s\n' "Compress='yes'" >> "/etc/systemd/journald.conf"
    tail -n "+$(( line_number ))" "${JOURNALD_REMEDY_CFG}.bak" >> "${JOURNALD_REMEDY_CFG}"
fi
# Clean up after ourselves.
rm "${JOURNALD_REMEDY_CFG}.bak"
