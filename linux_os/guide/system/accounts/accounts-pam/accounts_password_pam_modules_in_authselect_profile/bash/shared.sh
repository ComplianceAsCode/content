# platform = multi_platform_rhel

{{{ bash_check_authselect_integrity() }}}

{{{ bash_ensure_authselect_custom_profile() }}}

pam_profile="$(head -1 /etc/authselect/authselect.conf)"
if grep -Pq -- '^custom/' <<< "$pam_profile"; then
    pam_profile_path="/etc/authselect/$pam_profile"
else
    pam_profile_path="/usr/share/authselect/default/$pam_profile"
fi

# Function to add a missing PAM module to a file
# This function handles module placement based on typical PAM stack ordering
add_pam_module() {
    local authselect_file="$1"
    local module="$2"

    # Check if module already exists in any group
    if grep -Pq "^\s*\S+\s+\S+\s+$module" "$authselect_file"; then
        return 0
    fi

    # Special handling for pam_faillock.so - needs entries in auth and account groups
    if [ "$module" = "pam_faillock.so" ]; then
        # Add preauth entry in auth section (at the beginning of auth section)
        if ! grep -Pq "^\s*auth\s+\S+\s+$module" "$authselect_file"; then
            if grep -qP "^auth" "$authselect_file"; then
                FIRST_AUTH_LINE=$(grep -nP "^auth" "$authselect_file" | head -n 1 | cut -d: -f 1)
                if [ ! -z "$FIRST_AUTH_LINE" ]; then
                    sed -i --follow-symlinks "${FIRST_AUTH_LINE}i auth     required    pam_faillock.so preauth" "$authselect_file"
                fi
            else
                # If no auth section exists, create it at the beginning
                sed -i --follow-symlinks "1i auth     required    pam_faillock.so preauth" "$authselect_file"
            fi
        fi
        # Add entry in account section
        if ! grep -Pq "^\s*account\s+\S+\s+$module" "$authselect_file"; then
            if grep -qP "^account" "$authselect_file"; then
                FIRST_ACCOUNT_LINE=$(grep -nP "^account" "$authselect_file" | head -n 1 | cut -d: -f 1)
                if [ ! -z "$FIRST_ACCOUNT_LINE" ]; then
                    sed -i --follow-symlinks "${FIRST_ACCOUNT_LINE}a account     required    pam_faillock.so" "$authselect_file"
                fi
            else
                # If no account section exists, add it after auth section
                if grep -qP "^auth" "$authselect_file"; then
                    LAST_AUTH_LINE=$(grep -nP "^auth" "$authselect_file" | tail -n 1 | cut -d: -f 1)
                    if [ ! -z "$LAST_AUTH_LINE" ]; then
                        sed -i --follow-symlinks "${LAST_AUTH_LINE}a account     required    pam_faillock.so" "$authselect_file"
                    fi
                else
                    echo "account     required    pam_faillock.so" >> "$authselect_file"
                fi
            fi
        fi
        return 0
    fi

    # Handle pam_pwquality.so - goes in password section, before other password modules
    if [ "$module" = "pam_pwquality.so" ]; then
        if grep -qP "^password" "$authselect_file"; then
            FIRST_PASSWORD_LINE=$(grep -nP "^password" "$authselect_file" | head -n 1 | cut -d: -f 1)
            if [ ! -z "$FIRST_PASSWORD_LINE" ]; then
                sed -i --follow-symlinks "${FIRST_PASSWORD_LINE}i password     requisite    pam_pwquality.so" "$authselect_file"
            fi
        else
            # If no password section exists, add it after account section
            if grep -qP "^account" "$authselect_file"; then
                LAST_ACCOUNT_LINE=$(grep -nP "^account" "$authselect_file" | tail -n 1 | cut -d: -f 1)
                if [ ! -z "$LAST_ACCOUNT_LINE" ]; then
                    sed -i --follow-symlinks "${LAST_ACCOUNT_LINE}a password     requisite    pam_pwquality.so" "$authselect_file"
                fi
            else
                echo "password     requisite    pam_pwquality.so" >> "$authselect_file"
            fi
        fi
        return 0
    fi

    # Handle pam_pwhistory.so - goes in password section, after pam_pwquality
    if [ "$module" = "pam_pwhistory.so" ]; then
        if grep -qP "pam_pwquality\.so" "$authselect_file"; then
            # Add after pam_pwquality
            PWQUALITY_LINE=$(grep -nP "pam_pwquality\.so" "$authselect_file" | tail -n 1 | cut -d: -f 1)
            if [ ! -z "$PWQUALITY_LINE" ]; then
                sed -i --follow-symlinks "${PWQUALITY_LINE}a password     requisite    pam_pwhistory.so" "$authselect_file"
            fi
        elif grep -qP "^password" "$authselect_file"; then
            # Add at the beginning of password section if pam_pwquality not found
            FIRST_PASSWORD_LINE=$(grep -nP "^password" "$authselect_file" | head -n 1 | cut -d: -f 1)
            if [ ! -z "$FIRST_PASSWORD_LINE" ]; then
                sed -i --follow-symlinks "${FIRST_PASSWORD_LINE}i password     requisite    pam_pwhistory.so" "$authselect_file"
            fi
        else
            echo "password     requisite    pam_pwhistory.so" >> "$authselect_file"
        fi
        return 0
    fi

    # Handle pam_unix.so - typically appears in multiple groups (auth, account, password, session)
    # We'll add it to password group if missing, as that's most critical for this rule
    if [ "$module" = "pam_unix.so" ]; then
        # Check if it exists in password group
        if ! grep -Pq "^\s*password\s+\S+\s+$module" "$authselect_file"; then
            if grep -qP "pam_pwhistory\.so" "$authselect_file"; then
                # Add after pam_pwhistory
                PWHISTORY_LINE=$(grep -nP "pam_pwhistory\.so" "$authselect_file" | tail -n 1 | cut -d: -f 1)
                if [ ! -z "$PWHISTORY_LINE" ]; then
                    sed -i --follow-symlinks "${PWHISTORY_LINE}a password     sufficient    pam_unix.so" "$authselect_file"
                fi
            elif grep -qP "^password" "$authselect_file"; then
                # Add at the end of password section
                LAST_PASSWORD_LINE=$(grep -nP "^password" "$authselect_file" | tail -n 1 | cut -d: -f 1)
                if [ ! -z "$LAST_PASSWORD_LINE" ]; then
                    sed -i --follow-symlinks "${LAST_PASSWORD_LINE}a password     sufficient    pam_unix.so" "$authselect_file"
                fi
            else
                echo "password     sufficient    pam_unix.so" >> "$authselect_file"
            fi
        fi
        return 0
    fi
}

# Check and ensure modules are present in both system-auth and password-auth
for authselect_file in "$pam_profile_path"/system-auth "$pam_profile_path"/password-auth; do
    if [ ! -f "$authselect_file" ]; then
        echo "Warning: $authselect_file not found"
        continue
    fi
    for module in pam_pwquality.so pam_pwhistory.so pam_faillock.so pam_unix.so; do
        if ! grep -Pq "^\s*\S+\s+\S+\s+$module" "$authselect_file"; then
            add_pam_module "$authselect_file" "$module"
        fi
    done
done

authselect apply-changes
