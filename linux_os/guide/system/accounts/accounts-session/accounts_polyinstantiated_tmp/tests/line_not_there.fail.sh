#!/bin/bash
rm -rf /tmp-inst
mkdir --mode 000 /tmp-inst
sed -i "/^\s*\/tmp\s*/d" /etc/security/namespace.conf