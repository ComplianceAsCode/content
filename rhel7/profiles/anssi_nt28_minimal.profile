# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: false

title: 'DRAFT - ANSSI DAT-NT28 (minimal)'

description: 'Draft profile for ANSSI compliance at the minimal level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

selections:
    # R08 Regular updates
    - security_patches_up_to_date

    # ==============================================
    # R32 - Protection of stored passwords
    # In the file /etc/login.defs:
    # ENCRYPT_METHOD SHA512
    - set_password_hashing_algorithm_logindefs
    # SHA_CRYPT_MIN_ROUNDS 65536

    - sudo_remove_nopasswd
    - sudo_remove_no_authenticate
    - package_rsyslog_installed
    - service_rsyslog_enabled
    - file_permissions_etc_shadow
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_group
