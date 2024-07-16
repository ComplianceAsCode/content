#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
{{% if NO_QUOTES %}}
echo -e "[$SECTION]\n$PARAM=$VALUE" > "$MASTER_CFG_FILE"
{{% else %}}
echo -e "[$SECTION]\n$PARAM=\"$VALUE\"" > "$MASTER_CFG_FILE"
{{% endif %}}
