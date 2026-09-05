#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

result=$XCCDF_RESULT_PASS
while IFS=: read -r user _ uid _ _ home shell; do
    grep -qxF "$shell" /etc/shells 2>/dev/null || continue
    [[ "$shell" == */nologin || "$shell" == */false || ! -d "$home" ]] && continue
    case $(findmnt -no FSTYPE --target "$home" 2>/dev/null) in
        nfs|nfs4|cifs|smbfs|smb3|fuse.sshfs|afs|ncpfs|glusterfs|ceph) continue ;;
    esac
    while IFS= read -r -d '' dot_dir; do
        owner_uid=$(stat -Lc '%u' "$dot_dir")
        if [[ "$owner_uid" != "$uid" ]]; then
            echo "$dot_dir is owned by UID $owner_uid; expected $uid ($user)."
            result=$XCCDF_RESULT_FAIL
        fi
    done < <(find "$home" -xdev -mindepth 1 -maxdepth 1 -type d -name '.*' -print0 2>/dev/null)
done < /etc/passwd
exit "$result"
