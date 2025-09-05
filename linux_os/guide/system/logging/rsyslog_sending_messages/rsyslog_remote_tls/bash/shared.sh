# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}

# Get omfwd configuration directive
OMFWD_CONFIG_OUTPUT=`grep -Pzo '^(?s)action\s*\(\s*type\s*=\s*"omfwd".*\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf`
OMFWD_CONFIG=`echo "$OMFWD_CONFIG_OUTPUT"| awk 'BEGIN {FS=":"; RS=")\n"}; {print $2}'`
OMFWD_CONFIG_FILE=`echo "$OMFWD_CONFIG_OUTPUT"| awk 'BEGIN {FS=":"; RS=")\n"}; {print $1}'`
if ! [ -z "$OMFWD_CONFIG" ]; then
    OMFWD_TLS_STREAM=`echo "$OMFWD_CONFIG"|grep  'StreamDriver="gtls"'`
    if ! [ -z "${OMFWD_TLS_STREAM}" ]; then
        exit 0
    else
        # insert TLS stream param
        sed -i 's/action\s*(\s*type\s*=\s*"omfwd"/action(type="omfwd"\ StreamDriver="gtls"\ /' $OMFWD_CONFIG_FILE
    fi
else
    echo "action(type=\"omfwd\" protocol=\"tcp\" Target=\"$rsyslog_remote_loghost_address\" port=\"6514\" StreamDriver=\"gtls\" StreamDriverMode=\"1\" StreamDriverAuthMode=\"x509/name\" streamdriver.CheckExtendedKeyPurpose=\"on\")"  >> /etc/rsyslog.conf
fi
