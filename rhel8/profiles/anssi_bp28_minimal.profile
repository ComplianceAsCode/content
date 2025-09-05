documentation_complete: true

title: 'ANSSI BP-028 (minimal)'

description: 
    ANSSI BP-028 compliance at the minimal level. ANSSI stands for
    Agence nationale de la sécurité des systèmes d'information. Based on
    https://www.ssi.gouv.fr/.

selections:
    # Minimization of installed services
    - package_dhcp_removed
    - package_sendmail_removed
    - package_telnetd_removed

    # In-depth defense principle
    - sudo_remove_no_authenticate

    # * centralized logging of events at the systems and services level
    - package_rsyslog_installed
    - service_rsyslog_enabled

    # Regular updates
    - security_patches_up_to_date

    #  Package repositories selection
    # Only up-to-date official repositories of the distribution must be used.
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_never_disabled
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages

    # Administrator password robustness

    # Applications using PAM

    # Protecting stored passwords
    # In the file /etc/login.defs:
    # ENCRYPT_METHOD SHA512
    - set_password_hashing_algorithm_logindefs
    # SHA_CRYPT_MIN_ROUNDS 65536

    # Executables with setuid and/or setgid bits

    # In memory services and daemons

    # User authentication running sudo
    - sudo_remove_nopasswd

