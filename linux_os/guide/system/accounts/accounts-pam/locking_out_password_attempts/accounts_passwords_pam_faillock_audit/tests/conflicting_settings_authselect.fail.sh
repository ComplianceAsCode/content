
#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

source common.sh

echo "audit" > /etc/security/pam_faillock.conf

{{{ bash_pam_faillock_enable() }}}

for file in ${pam_files[@]}; do
    if grep -q "pam_faillock\.so.*audit" "$CUSTOM_PROFILE_DIR/$file" ; then
        echo "auth required pam_faillock.so preauth audit" >> \
        "$CUSTOM_PROFILE_DIR/$file"
    fi
done

authselect apply-changes
