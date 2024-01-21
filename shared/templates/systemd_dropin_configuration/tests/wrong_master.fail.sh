#!/bin/bash
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
echo "$PARAM=badval" >> "$MASTER_CFG_FILE"
