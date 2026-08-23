#!/bin/bash
# platform = multi_platform_ubuntu

source common.sh

echo "${CONF}" >> "${FILE_PATH}"
CONF="${CONF_PREFIX}non-valid-256${CONF_SUFIX}"
echo "${CONF}" >> "${FILE_PATH}"
