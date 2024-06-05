#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
echo -e "[$SECTION]\n$PARAM=$VALUE" >> "$DROPIN_DIR/ssg.conf"
