#!/bin/bash

JRE_CONFIG_FILE="/usr/lib/jvm/jre/lib/security/java.security"

mkdir -p $(dirname $JRE_CONFIG_FILE)
touch $JRE_CONFIG_FILE
