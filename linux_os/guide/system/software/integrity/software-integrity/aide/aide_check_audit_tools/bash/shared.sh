# platform = multi_platform_rhel, multi_platform_fedora, multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

package_install aide || exit 1

aide_conf="/etc/aide.conf"

tools="auditctl auditd ausearch aureport autrace audispd augenrules"

for tool in $tools ; do
    if ! grep -x -q -F "/usr/sbin/$tool p+i+n+u+g+s+b+acl+selinux+xattrs+sha512" "$aide_conf" ; then
        if grep -q "^/usr/sbin/$tool\s" "$aide_conf" ; then
            sed -i --follow-symlinks -E -e 's/^\/usr\/sbin\/'"$tool"'\s[^\n]*/\/usr\/sbin\/'"$tool"' p+i+n+u+g+s+b+acl+selinux+xattrs+sha512/' "$aide_conf" || exit 1
        else
            echo "/usr/sbin/$tool p+i+n+u+g+s+b+acl+selinux+xattrs+sha512" >> "$aide_conf" || exit 1
        fi
    fi
done

true
