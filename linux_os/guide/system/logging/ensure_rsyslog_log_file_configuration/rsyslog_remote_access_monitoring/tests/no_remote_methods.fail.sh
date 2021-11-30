#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ubuntu

declare -A REMOTE_METHODS=( ['auth.*']='^.*auth\.\*.*$' ['authpriv.*']='^.*authpriv\.\*.*$' ['daemon.*']='^.*daemon\.\*.*$' )
RSYSLOG_CONF='/etc/rsyslog.conf'

# At least ensure that rsyslog.conf exist
test -f ${RSYSLOG_CONF} || touch ${RSYSLOG_CONF}

for K in ${!REMOTE_METHODS[@]}
do
    # Make sure remote methods are not in rsyslog.conf
    if grep -q "${REMOTE_METHODS[$K]}" ${RSYSLOG_CONF}; then
        sed -i "/${REMOTE_METHODS[$K]}/d" ${RSYSLOG_CONF}
    fi
done
