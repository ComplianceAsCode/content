#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
{{% if NO_QUOTES %}}
echo -e "[$SECTION]\n$PARAM=$VALUE" > "$DROPIN_DIR/ssg.conf"
{{% else %}}
echo -e "[$SECTION]\n$PARAM=\"$VALUE\"" > "$DROPIN_DIR/ssg.conf"
{{% endif %}}
