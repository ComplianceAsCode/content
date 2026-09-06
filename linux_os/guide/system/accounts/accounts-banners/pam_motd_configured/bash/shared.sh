# platform = Ubuntu 26.04
# reboot = false
# strategy = configure
# complexity = medium
# disruption = medium

os_id=$(awk -F= '$1 == "ID" { gsub(/^"|"$/, "", $2); print $2; exit }' /etc/os-release 2>/dev/null)
touch /etc/motd
chown root:root /etc/motd
chmod u-x,go-wx /etc/motd

append_canonical_entry() {
    local pam_file=$1
    if [[ -s "$pam_file" && -n $(tail -c 1 "$pam_file") ]]; then
        printf '\n' >> "$pam_file"
    fi
    printf '%s\n' 'session optional pam_motd.so motd=/etc/motd' >> "$pam_file"
}

configured=false
for pam_file in /etc/pam.d/*; do
    [[ -f "$pam_file" ]] || continue
    if grep -Piq '^\h*session\h+(required|optional)\h+pam_motd\.so\b' "$pam_file"; then
        sed -ri '/^[[:space:]]*session[[:space:]]+(required|optional)[[:space:]]+pam_motd\.so\b/Id' "$pam_file"
        append_canonical_entry "$pam_file"
        configured=true
    fi
done

if [[ "$configured" != true ]]; then
    for service in sshd login su gdm-password; do
        pam_file="/etc/pam.d/$service"
        [[ -f "$pam_file" ]] || continue
        append_canonical_entry "$pam_file"
        break
    done
fi

sed -ri 's/\\[vrms]//g; s/(Ubuntu|Debian|GNU\/Linux)//Ig' /etc/motd
if [[ -n "$os_id" ]]; then
    sed -ri "s/\\b${os_id}\\b//Ig" /etc/motd
fi
