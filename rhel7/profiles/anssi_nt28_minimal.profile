documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (minimal)'

description: 'Draft profile for ANSSI compliance at the minimal level. ANSSI stands for Agence nationale de la sécurité des
    systèmes d''information. Based on https://www.ssi.gouv.fr/.'

selections:
    # ==============================================
    # R1 - Minimization of installed services
    # Only the components strictly necessary to the service provided by the system
    # should be installed.
    # Any service (especially in active listening on the network) is a sensitive
    # element. Only those known and required for the operation and the maintenance
    # must be resident. Those whose presence can not be justified should be disabled,
    # removed or deleted.
    - package_dhcp_removed
    - package_sendmail_removed
    - package_telnetd_removed

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
    # Only up-to-date official repositories of the distribution must be used.
    - ensure_redhat_gpgkey_installed
    - ensure_gpgcheck_never_disabled
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_local_packages

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

