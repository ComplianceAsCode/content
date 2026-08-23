#!/bin/bash

rm -rf /var/tmp/tmp-inst
mkdir -p --mode 000 /var/tmp/tmp-inst
chmod 000 /var/tmp/tmp-inst
sed -i "/^\s*\/var\/tmp\s*/d" /etc/security/namespace.conf
