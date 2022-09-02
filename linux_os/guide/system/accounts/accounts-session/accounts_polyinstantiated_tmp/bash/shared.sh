{{%- set basedir="/tmp" -%}}
# platform = multi_platform_all
if ! [ -d {{{ basedir }}}/tmp-inst ] ; then
    mkdir --mode 000 {{{ basedir }}}/tmp-inst
fi
chmod 000 {{{ basedir }}}/tmp-inst
chcon --reference={{{ basedir }}}/ {{{ basedir }}}/tmp-inst

if ! grep -Eq '^\s*{{{ basedir }}}\s+{{{ basedir }}}/tmp-inst/\s+level\s+root,adm\s*$' /etc/security/namespace.conf ; then
    if grep -Eq '^\s*{{{ basedir }}}\s+' /etc/security/namespace.conf ; then
        sed -i '/^\s*\{{{ basedir }}}/d' /etc/security/namespace.conf
    fi
    echo "{{{ basedir }}} {{{ basedir }}}/tmp-inst/    level      root,adm" >> /etc/security/namespace.conf
fi
