#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_pci-dss

auth_files[0]="/etc/pam.d/system-auth"
auth_files[1]="/etc/pam.d/password-auth"

# Make sure pam_faillock is configured,
# value of var_accounts_passwords_pam_faillock_unlock_time for PCI-DSS profile is 1800
for file in "${auth_files[@]}" ; do
    sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent '"unlock_time"'='"1800" "$file"
    sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail '"unlock_time"'='"1800" "$file"
    sed -E -i --follow-symlinks '/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so' "$file"
done
