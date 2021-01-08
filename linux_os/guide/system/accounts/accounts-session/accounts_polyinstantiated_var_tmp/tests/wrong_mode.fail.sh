#!/bin/bash
rm -rf /var/tmp/tmp-inst
mkdir --mode 600 /var/tmp/tmp-inst
echo "/var/tmp /var/tmp/tmp-inst/    level      root,adm" >> /etc/security/namespace.conf