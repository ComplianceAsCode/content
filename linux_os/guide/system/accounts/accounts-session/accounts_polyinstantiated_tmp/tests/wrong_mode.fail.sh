#!/bin/bash
{{%- set basedir="/tmp" -%}}
rm -rf {{{ basedir }}}/tmp-inst
mkdir --mode 600 {{{ basedir }}}/tmp-inst
rm -rf /etc/security/namespace.d
sed -i '\,^\s*{{{ basedir }}}\s,d' /etc/security/namespace.conf
echo "{{{ basedir }}} {{{ basedir }}}/tmp-inst/    level      root,adm" >> /etc/security/namespace.conf
