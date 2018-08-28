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
    - apt_conf_disallow_unauthenticated
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
