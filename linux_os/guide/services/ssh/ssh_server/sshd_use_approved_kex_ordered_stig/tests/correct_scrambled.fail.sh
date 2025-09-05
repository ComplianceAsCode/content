#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

source common.sh

readarray -t KEX_ALGOS_ARR < <(echo $KEX_ALGOS | tr "," "\n")

#swap first and second algorithms

KEX_ALGOS_SCRAMBLED=$(echo ${KEY_ALGOS_ARR[0]},${KEY_ALGOS_ARR[1]},$(echo ${KEY_ALGOS_ARR[@]:2} | tr " " ","))

CONF="${CONF_PREFIX}${KEX_ALGOS_SCRAMBLED}${CONF_SUFIX}"

echo "${CONF}" >> "${FILE_PATH}"
