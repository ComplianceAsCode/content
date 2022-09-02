#!/bin/bash
{{%- set basedir="/tmp" -%}}
rm -rf {{{ basedir }}}/tmp-inst
mkdir --mode 000 {{{ basedir }}}/tmp-inst
rm -rf /etc/security/namespace.d
sed -i '\,^\s*{{{ basedir }}}\s,d' /etc/security/namespace.conf
echo "{{{ basedir }}} {{{ basedir }}}/tmp-inst/    level:iscript=foo.sh:shared:noinit      root,adm" >> /etc/security/namespace.conf
