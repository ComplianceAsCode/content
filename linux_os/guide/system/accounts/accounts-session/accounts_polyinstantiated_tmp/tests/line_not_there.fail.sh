#!/bin/bash
{{%- set basedir="/tmp" -%}}
rm -rf {{{ basedir }}}/tmp-inst
rm -rf /etc/security/namespace.d
sed -i '\,^\s*{{{ basedir }}}\s,d' /etc/security/namespace.conf
