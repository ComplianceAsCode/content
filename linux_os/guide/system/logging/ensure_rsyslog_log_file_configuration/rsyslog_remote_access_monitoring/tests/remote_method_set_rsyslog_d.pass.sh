#!/bin/bash
# platform = multi_platform_all

declare -A REMOTE_METHODS=( ['auth.*']='^.*auth\.\*.*$' ['authpriv.*']='^.*authpriv\.\*.*$' ['daemon.*']='^.*daemon\.\*.*$' )
RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILE=$RSYSLOG_D_FOLDER'/test.conf'

# Ensure that rsyslog.d folder exists and contains our 'test' file
mkdir -p ${RSYSLOG_D_FOLDER}
touch ${RSYSLOG_D_FILE}

test -f ${RSYSLOG_CONF} || touch ${RSYSLOG_CONF}

for K in ${!REMOTE_METHODS[@]}
do
    # Make sure remote methods are not in rsyslog.conf
    if grep -q "${REMOTE_METHODS[$K]}" ${RSYSLOG_CONF}; then
        sed -i "/${REMOTE_METHODS[$K]}/d" ${RSYSLOG_CONF}
    fi

    # Add remote methods to test file
    echo "${K} \/var\/log\/secure/" >> ${RSYSLOG_D_FILE}
done
