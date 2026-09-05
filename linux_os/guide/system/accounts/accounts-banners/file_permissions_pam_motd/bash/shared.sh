# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

while IFS= read -r motd_path; do
    motd_path=${motd_path#\"}; motd_path=${motd_path%\"}
    motd_path=${motd_path#\'}; motd_path=${motd_path%\'}
    [[ -e "$motd_path" ]] || continue
    chown root:root "$motd_path"
    chmod u-x,go-wx "$motd_path"
done < <(grep -hPoi '^\h*session\h+(required|optional)\h+pam_motd\.so\b.*\bmotd=\K("[^"]+"|'"'"'[^'"'"']+'"'"'|\S+)' /etc/pam.d/* 2>/dev/null | sort -u)
