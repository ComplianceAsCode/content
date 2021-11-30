#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ubuntu

declare -A REMOTE_METHODS=( ['auth.*']='^.*auth\.\*.*$' ['authpriv.*']='^.*authpriv\.\*.*$' ['daemon.*']='^.*daemon\.\*.*$' )
RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'

# Ensure that rsyslog.d folder exists
mkdir -p ${RSYSLOG_D_FOLDER}

# At least ensure that rsyslog.conf exist
test -f ${RSYSLOG_CONF} || touch ${RSYSLOG_CONF}

# Clean slate:
for K in ${!REMOTE_METHODS[@]}
do
    # Make sure remote methods are not in rsyslog.conf
    if grep -q "${REMOTE_METHODS[$K]}" ${RSYSLOG_CONF}; then
        sed -i "/${REMOTE_METHODS[$K]}/d" ${RSYSLOG_CONF}
    fi
done

# Mix both rsyslog.conf + .d/*.conf files (possible scenario)
KEYS=("${!REMOTE_METHODS[@]}")
echo "${KEYS[0]} /var/log/secure" >> ${RSYSLOG_CONF}
echo "${KEYS[1]} /var/log/secure" > ${RSYSLOG_D_FOLDER}/test1.conf
echo "${KEYS[2]} /var/log/secure" > ${RSYSLOG_D_FOLDER}/test2.conf
