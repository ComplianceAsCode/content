#!/bin/bash
rm -rf /tmp-inst
mkdir --mode 600 /tmp-inst
echo "/tmp     /tmp-inst/            level      root,adm" >> /etc/security/namespace.conf