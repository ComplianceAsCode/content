#!/bin/bash

function set_parameters_value {
        if [ -z "$1" ]; then
                echo "Specify file name"
                exit 1
        elif [ -z "$2" ]; then
                echo "Specify paramaters name"
                exit 1
        elif [ -z "$3" ]; then
                echo "Specify parameters value"
                exit 1
        fi

        local FILE=$1 PARAMETER=$2 VALUE=$3

        yum install -y audit

        REGEX="^$PARAMETER[[:space:]]*=.*$"
        if grep -q "$REGEX" "$FILE"; then
                sed -i "s~$REGEX~$PARAMETER = $VALUE~" "$FILE"
        else
                echo "$PARAMETER = $VALUE" >> "$FILE"
        fi
}
