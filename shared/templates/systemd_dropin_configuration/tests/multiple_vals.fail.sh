#!/bin/bash
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
echo "$PARAM=$VALUE" >> "$DROPIN_DIR/ssg.conf"
echo "$PARAM=badval" >> "$DROPIN_DIR/gss.conf"
echo "$PARAM=foobarzoo" >> "$MASTER_CFG_FILE"
