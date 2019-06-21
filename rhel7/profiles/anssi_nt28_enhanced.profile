# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: false

title: 'DRAFT - ANSSI DAT-NT28 (enhanced)'

description: 'Draft profile for ANSSI compliance at the enhanced level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_intermediary

selections:
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_sgid
    - rsyslog_remote_loghost

    # R29 User session timeout
    - accounts_tmout
    - sshd_set_idle_timeout
