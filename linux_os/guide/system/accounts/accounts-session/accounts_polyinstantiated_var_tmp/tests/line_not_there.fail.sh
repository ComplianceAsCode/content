#!/bin/bash
{{%- set basedir="/var/tmp" -%}}
rm -rf {{{ basedir }}}/tmp-inst
rm -rf /etc/security/namespace.d
sed -i '\,^\s*{{{ basedir }}}\s,d' /etc/security/namespace.conf
