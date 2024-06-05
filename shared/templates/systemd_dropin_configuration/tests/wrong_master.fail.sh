#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
echo -e "[$SECTION]\n$PARAM=badval" >> "$MASTER_CFG_FILE"
