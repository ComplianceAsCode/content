#!/bin/bash
{{%- set basedir="/var/tmp" -%}}
rm -rf {{{ basedir }}}/tmp-inst
mkdir --mode 000 {{{ basedir }}}/tmp-inst
mkdir -p /etc/security/namespace.d
touch /etc/security/namespace.d/nothing.conf
sed -i '\,^\s*{{{ basedir }}}\s,d' /etc/security/namespace.conf /etc/security/namespace.d/*.conf
echo " {{{ basedir }}}  {{{ basedir }}}/tmp-inst/	user:create=0700:noinit:iscript=shared.sh		~user,foo-bar		" >> /etc/security/namespace.d/10-local.conf
