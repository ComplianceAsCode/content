#!/bin/bash
rm -rf /tmp/tmp-inst
mkdir --mode 000 /tmp/tmp-inst
echo "/tmp     /tmp/tmp-inst/        level      root,adm" >> /etc/security/namespace.conf
