#!/bin/bash
SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
VALUE="{{{ VALUE }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"

# This setup tests if remediation is "tricked" by a commented-out correct value.
# It sets an active bad value and a commented-out good value.
{{% if NO_QUOTES %}}
echo -e "[$SECTION]\n$PARAM=badval\n#$PARAM=$VALUE" > "$MASTER_CFG_FILE"
{{% else %}}
echo -e "[$SECTION]\n$PARAM=\"badval\"\n#$PARAM=\"$VALUE\"" > "$MASTER_CFG_FILE"
{{% endif %}}
