#!/bin/bash
# platform = multi_platform_all

declare -A REMOTE_METHODS=( ['auth.*']='^.*auth\.\*.*$' ['authpriv.*']='^.*authpriv\.\*.*$' ['daemon.*']='^.*daemon\.\*.*$' )
RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILES='/etc/rsyslog.d/*'


# clean up .d conf files (if applicable)
if [[ -d ${RSYSLOG_D_FOLDER} ]]; then
	for rsyslog_d_file in ${RSYSLOG_D_FILES}
	do
		for K in ${!REMOTE_METHODS[@]}
		do
			if grep -q "$K" ${rsyslog_d_file}; then
				sed -i "/$K/d" ${rsyslog_d_file}
			fi
		done
	done
fi

if [[ ! -f /etc/rsyslog.conf ]]; then
	# Something is not right, create the file
	touch /etc/rsyslog.conf
fi

echo "auth.*;authpriv.* /var/log/secure" >> $RSYSLOG_CONF
echo "daemon.* /var/log/messages" >> $RSYSLOG_CONF
