documentation_complete: true

title: 'Profile for ANSSI DAT-NT28 Minimal Level'

description: 'This profile contains items to be applied systematically.'

selections:
    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - package_telnetd_removed
    - package_inetutils-telnetd_removed
    - package_telnetd-ssl_removed
    - package_nis_removed
    - package_rsyslog_installed
    - service_rsyslog_enabled
    - package_syslogng_installed
    - service_syslogng_enabled
    - apt_conf_disallow_unauthenticated
    - apt_sources_list_official
    - file_permissions_etc_shadow
    - file_owner_etc_shadow
    - file_groupowner_etc_shadow
    - file_permissions_etc_gshadow
    - file_owner_etc_gshadow
    - file_groupowner_etc_gshadow
    - file_permissions_etc_passwd
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_group
    - file_owner_etc_group
    - file_groupowner_etc_group
