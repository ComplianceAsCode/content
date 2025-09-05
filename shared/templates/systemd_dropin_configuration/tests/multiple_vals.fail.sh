#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
[ -d $DROPIN_DIR ] || mkdir -p $DROPIN_DIR
{{% if NO_QUOTES %}}
echo -e "[$SECTION]\n$PARAM=$VALUE" > "$DROPIN_DIR/ssg.conf"
echo -e "[$SECTION]\n$PARAM=badval" > "$DROPIN_DIR/gss.conf"
echo -e "[$SECTION]\n$PARAM=foobarzoo" > "$MASTER_CFG_FILE"
{{% else %}}
echo -e "[$SECTION]\n$PARAM=\"$VALUE\"" > "$DROPIN_DIR/ssg.conf"
echo -e "[$SECTION]\n$PARAM=\"badval\"" > "$DROPIN_DIR/gss.conf"
echo -e "[$SECTION]\n$PARAM=\"foobarzoo\"" > "$MASTER_CFG_FILE"
{{% endif %}}
