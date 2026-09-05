# platform = Ubuntu 26.04
# reboot = false
# strategy = configure
# complexity = medium
# disruption = medium

os_id=$(awk -F= '$1 == "ID" { gsub(/^"|"$/, "", $2); print $2; exit }' /etc/os-release 2>/dev/null)
touch /etc/motd
chown root:root /etc/motd
chmod u-x,go-wx /etc/motd

for service in sshd login su gdm-password; do
    pam_file="/etc/pam.d/$service"
    [[ -f "$pam_file" ]] || continue
    sed -ri '/^[[:space:]]*session[[:space:]]+(required|optional)[[:space:]]+pam_motd\.so\b/I {/\bmotd=/! s#[[:space:]]*$# motd=/etc/motd#}' "$pam_file"
done

while IFS= read -r motd_path; do
    motd_path=${motd_path#\"}; motd_path=${motd_path%\"}
    motd_path=${motd_path#\'}; motd_path=${motd_path%\'}
    [[ -f "$motd_path" ]] || continue
    sed -ri 's/\\[vrms]//g; s/(Ubuntu|Debian|GNU\/Linux)//Ig' "$motd_path"
    if [[ -n "$os_id" ]]; then
        sed -ri "s/\\b${os_id}\\b//Ig" "$motd_path"
    fi
done < <(grep -hPoi '^\h*session\h+(required|optional)\h+pam_motd\.so\b.*\bmotd=\K("[^"]+"|'"'"'[^'"'"']+'"'"'|\S+)' /etc/pam.d/* 2>/dev/null | sort -u)
