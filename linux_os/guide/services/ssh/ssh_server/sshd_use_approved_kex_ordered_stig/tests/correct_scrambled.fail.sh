#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

source common.sh

readarray -t KEX_ALGOS_ARR < <(echo $KEX_ALGOS | tr "," "\n")

#swap first and second algorithms

KEX_ALGOS_SCRAMBLED=$(echo ${KEX_ALGOS_ARR[1]},${KEX_ALGOS_ARR[0]},$(echo ${KEX_ALGOS_ARR[@]:2} | tr " " ","))

CONF="${CONF_PREFIX}${KEX_ALGOS_SCRAMBLED}${CONF_SUFIX}"

echo "${CONF}" >> "${FILE_PATH}"
