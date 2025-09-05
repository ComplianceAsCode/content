#!/bin/bash
PARAM="{{{ PARAM }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
echo "$PARAM=badval" >> "$DROPIN_DIR/ssg.conf"
