#!/bin/bash

RSYSLOG_CONF='/etc/rsyslog.conf'
LOG_FILE_PREFIX=test
RSYSLOG_TEST_DIR=/tmp
declare -a RSYSLOG_TEST_LOGS

# This function creates test rsyslog log files
# Parameters: $1 - number of log files to be created
function create_rsyslog_test_logs {
        local count=$1

        RSYSLOG_TEST_DIR=$(mktemp -d)
        RSYSLOG_TEST_LOGS=()

        if [ $? -ne 0 ]; then
            echo "Failed to create RSYSLOG_TEST_DIR"
            exit 1
        fi

        if ! [[ "$count" =~ ^[0-9]+$ ]] || [ $count -eq 0 ]; then
            echo "Argument 'count' is not a positive number: $count"
            exit 1
        fi

        for ind in $(seq 1 $count); do
            local testlog=${RSYSLOG_TEST_DIR}/${LOG_FILE_PREFIX}${ind}.log
            touch ${testlog}
            RSYSLOG_TEST_LOGS+=("${testlog}")
        done;
}
