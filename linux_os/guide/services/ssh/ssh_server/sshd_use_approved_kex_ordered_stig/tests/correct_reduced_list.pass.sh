#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

source common.sh

KEX_ALGOS_REDUCED=$(echo $KEX_ALGOS | sed -E 's/,.*,/,/')

CONF="${CONF_PREFIX}${KEX_ALGOS_REDUCED}${CONF_SUFIX}"

echo "${CONF}" >> "${FILE_PATH}"
