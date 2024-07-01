#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
echo -e "[$SECTION]\n$PARAM=$VALUE" >> "$MASTER_CFG_FILE"
