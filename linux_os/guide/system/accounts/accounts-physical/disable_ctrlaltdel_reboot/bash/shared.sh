# platform = multi_platform_all
if {{{ bash_bootc_build() }}} ; then
    systemctl disable ctrl-alt-del.target
    systemctl mask ctrl-alt-del.target
else
    systemctl disable --now ctrl-alt-del.target
    systemctl mask --now ctrl-alt-del.target
fi
