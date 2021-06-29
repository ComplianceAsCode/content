# platform = Red Hat Enterprise Linux 8,multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("sshd_approved_macs") }}}

CONF_FILE=/etc/crypto-policies/back-ends/opensshserver.config
correct_value="-oMACs=${sshd_approved_macs}"

grep -q ${correct_value} ${CONF_FILE}

if [[ $? -ne 0 ]]; then
    # We need to get the existing value, using PCRE to maintain same regex
    existing_value=$(grep -Po '(-oMACs=\S+)' ${CONF_FILE})

    if [[ ! -z ${existing_value} ]]; then
        # replace existing_value with correct_value
        sed -i "s/${existing_value}/${correct_value}/g" ${CONF_FILE}
    else
        # ***NOTE*** #
        # This probably means this file is not here or it's been modified
        # unintentionally.
        # ********** #
        # echo correct_value to end
        echo ${correct_value} >> ${CONF_FILE}
    fi
fi
