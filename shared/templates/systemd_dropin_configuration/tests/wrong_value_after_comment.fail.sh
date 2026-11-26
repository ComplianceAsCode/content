#!/bin/bash

SECTION="{{{ SECTION }}}"
PARAM="{{{ PARAM }}}"
MASTER_CFG_FILE="{{{ MASTER_CFG_FILE }}}"
DROPIN_DIR="{{{ DROPIN_DIR }}}"

mkdir -p "$DROPIN_DIR"
rm -f "$DROPIN_DIR"/*.conf

# Keep both locations noncompliant so a new drop-in cannot mask a missed section.
for config_file in "$MASTER_CFG_FILE" "$DROPIN_DIR/ssg.conf"; do
{{% if NO_QUOTES %}}
    printf '# Configuration header\n[%s]\n%s=badval\n' "$SECTION" "$PARAM" > "$config_file"
{{% else %}}
    printf '# Configuration header\n[%s]\n%s="badval"\n' "$SECTION" "$PARAM" > "$config_file"
{{% endif %}}
done
