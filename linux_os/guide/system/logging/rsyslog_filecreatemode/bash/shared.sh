# platform = multi_platform_ubuntu

{{{ bash_package_install("rsyslog") }}}

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/*
echo '$FileCreateMode 0640' > /etc/rsyslog.d/99-rsyslog_filecreatemode.conf
systemctl restart rsyslog.service
