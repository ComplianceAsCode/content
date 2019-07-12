documentation_complete: true

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

    # ==============================================
    # R59 - User authentication running sudo
    # An authentication of the calling user must be done before any command execution with sudo.
    # The keyword NOPASSWD must not be used.
    - sudo_remove_nopasswd

    - sudo_remove_no_authenticate
    - package_rsyslog_installed
    - service_rsyslog_enabled
