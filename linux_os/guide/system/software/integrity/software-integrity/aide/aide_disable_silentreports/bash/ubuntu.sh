# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_package_install("aide") }}}

if ! grep -i "^SILENTREPORTS*=*no$" {{{ aide_default_path }}}
then
sed -i "^((#+(\s*)SILENTREPORTS)|(SILENTREPORTS(\s*)=(\s*)yes))" "SILENTREPORTS=no" {{{ aide_default_path }}}
fi
