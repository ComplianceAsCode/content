documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (minimal)'

description: 'Draft profile for ANSSI compliance at the minimal level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

selections:
    # ==============================================
    # R1 - Minimization of installed services

    # ==============================================
    # R5 - In-depth defense principle
    # Under Unix and derivatives, defense in depth must be based on a combination
    # of barriers that must be kept independent of each other. For example :
    # * authentication necessary before carrying out operations, especially when
    #   they are privileged;
    - sudo_remove_no_authenticate

    # * centralized logging of events at the systems and services level;
    - package_rsyslog_installed
    - service_rsyslog_enabled

    # * priority to the use of services that implement partitioning mechanisms
    #   and / or separation of privileges;
    # * use of exploits prevention mechanisms.

    # ==============================================
    # R8 - Regular updates
    - security_patches_up_to_date

    # ==============================================
    # R15 - Package repositories selection

    # ==============================================
    # R18 - Administrator password robustness

    # ==============================================
    # R30 - Applications using PAM

    # ==============================================
    # R32 - Protecting stored passwords
    # In the file /etc/login.defs:
    # ENCRYPT_METHOD SHA512
    - set_password_hashing_algorithm_logindefs
    # SHA_CRYPT_MIN_ROUNDS 65536

    # ==============================================
    # R37 - Executables with setuid and/or setgid bits

    # ==============================================
    # R42 - In memory services and daemons

    # ==============================================
    # R59 - User authentication running sudo
    # An authentication of the calling user must be done before any command execution with sudo.
    # The keyword NOPASSWD must not be used.
    - sudo_remove_nopasswd

