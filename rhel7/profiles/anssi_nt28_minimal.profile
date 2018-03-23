documentation_complete: true

title: 'ANSSI DAT-NT28 (minimal)'

description: 'Draft profile for ANSSI compliance at the minimal level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

selections:
    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - package_rsyslog_installed
    - service_rsyslog_enabled
    - file_permissions_etc_shadow
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_group
