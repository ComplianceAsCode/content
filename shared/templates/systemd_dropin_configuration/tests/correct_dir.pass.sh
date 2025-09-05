#!/bin/bash
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
echo "$PARAM=$VALUE" >> "$DROPIN_DIR/ssg.conf"
