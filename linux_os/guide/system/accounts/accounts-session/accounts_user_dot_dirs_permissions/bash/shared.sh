# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = medium
# disruption = medium

while IFS=: read -r _ _ _ _ _ home shell; do
    grep -qxF "$shell" /etc/shells 2>/dev/null || continue
    [[ "$shell" == */nologin || "$shell" == */false || ! -d "$home" ]] && continue
    case $(findmnt -no FSTYPE --target "$home" 2>/dev/null) in
        nfs|nfs4|cifs|smbfs|smb3|fuse.sshfs|afs|ncpfs|glusterfs|ceph) continue ;;
    esac
    while IFS= read -r -d '' dot_dir; do
        if [[ ${dot_dir##*/} == .ssh ]]; then
            chmod go-rwx "$dot_dir"
        else
            chmod g-w,o-rwx "$dot_dir"
        fi
    done < <(find "$home" -xdev -mindepth 1 -maxdepth 1 -type d -name '.*' -print0 2>/dev/null)
done < /etc/passwd
