#!/bin/bash

rm -rf /var/tmp/tmp-inst
echo "/var/tmp /var/tmp/tmp-inst/    level      root,adm" >> /etc/security/namespace.conf
