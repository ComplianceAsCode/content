# platform = multi_platform_ubuntu

{{{ bash_package_install("aide") }}}

/usr/sbin/aideinit
/bin/mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
