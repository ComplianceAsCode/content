#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

. common.sh

echo "security.useSystemPropertiesFile=false" > $JRE_CONFIG_FILE
