#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle

source common.sh

CONF="${CONF_PREFIX}${CONF_SUFIX}"

echo "${CONF}" >> "${FILE_PATH}"
