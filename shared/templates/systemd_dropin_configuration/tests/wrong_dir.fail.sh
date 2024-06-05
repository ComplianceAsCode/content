#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
echo -e "[$SECTION]\n$PARAM=badval" >> "$DROPIN_DIR/ssg.conf"
