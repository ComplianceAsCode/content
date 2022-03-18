# platform = multi_platform_ol,multi_platform_rhel
#!/bin/bash

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf

DIR1=/var/log/audit/
DIR2=/var/log/audit2/

mkdir ${DIR2}
