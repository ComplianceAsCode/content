#!/bin/bash

function delete_parameter {
        if [ -z "$1" ]; then
                echo "Specify file name"
                exit 1
        elif [ -z "$2" ]; then
                echo "Specify parameters name"
                exit 1
        fi

        local FILE=$1 PARAMETER=$2

        yum install -y audit

        sed -i "/^$PARAMETER[[:space:]]*=/d" "$FILE"
}
