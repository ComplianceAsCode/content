# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora

{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}

CONF_FILE=/etc/crypto-policies/back-ends/opensshserver.config
LOCAL_CONF_DIR=/etc/crypto-policies/local.d
LOCAL_CONF_FILE=${LOCAL_CONF_DIR}/opensshserver-ssg.config
correct_value="-oCiphers=${sshd_approved_ciphers}"

# Test if file exists, create default it if not
if [[ ! -s ${CONF_FILE} ]] || ! grep -q "^\s*CRYPTO_POLICY=" ${CONF_FILE} ; then
    update-crypto-policies --no-reload # Generate a default configuration
fi

# Get the last occurrence of CRYPTO_POLICY
last_crypto_policy=$(grep -Eo "^\s*CRYPTO_POLICY='[^']+'" ${CONF_FILE} | tail -n 1)

# Copy the last CRYPTO_POLICY value to the local configuration file
if [[ -n "$last_crypto_policy" ]]; then
    if ! grep -qe "$correct_value" <<< "$last_crypto_policy"; then
        # If an existing -oCiphers= is found, replace it
        # Else, append correct_value before the closing apostrophe
        if [[ "$last_crypto_policy" == *"-oCiphers="* ]]; then
            last_crypto_policy=$(echo "$last_crypto_policy" | sed -E "s/-oCiphers=\S+/${correct_value}/")
        else
            last_crypto_policy=$(echo "$last_crypto_policy" | sed -E "s/'[[:space:]]*$/ ${correct_value}'/")
        fi
        # Write updated line to LOCAL_CONF_FILE
        echo -e "\n$last_crypto_policy" > "$LOCAL_CONF_FILE"
    fi
else
    echo -e "\nCRYPTO_POLICY='${correct_value}'" > ${LOCAL_CONF_FILE}
fi

update-crypto-policies --no-reload
