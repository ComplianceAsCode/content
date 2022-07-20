# This is a modified OSPP profile from v0.1.43

documentation_complete: true

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2).

selections:

    #######################################################
    # 5.1.1 Cryptographic Support (FCS)

    #######################################################
    ## FCS_CKM.1 Cryptographic Key Generation

    ### FCS_CKM.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_CKM.1.1
    ### The OS shall generate asymetric cryptographic
    ### keys in accordance with a specified cryptographic key
    ### generation algorithm.


    ### FCS_CKM.2.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_CKM.2.1
    ### The OS shall implement functionality to perform cryptographic
    ### key establishment in accordance with a specified cryptographic
    ### key establishment method

    #######################################################
    ## FCS_CKM_EXT.4 Cryptographic Key Destruction

    ### FCS_CKM_EXT.4.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_CKM_EXT.4.1
    ### The OS shall destroy cryptographic keys and key material in accordance
    ### with a specified cryptographic key destruction method

    ### FCS_CKM_EXT.4.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_CKM_EXT.4.2
    ### The OS shall destroy all keys and key material when no longer needed

    #######################################################
    ## FCS_COP.1(1) Cryptographic Operation - Encryption/Decryption (Refined)

    ### FCS_COP.1.1(1): https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_COP.1.1(1)
    ### The OS shall perform encryption/decryption services for data
    ### in accorance with a specified cryptographic algorithm

    #######################################################
    ## FCS_COP.1(2) Cryptographic Operation - Hashing (Refined)

    ### FCS_COP.1.1(2): https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_COP.1.1(2)
    ### The OS shall perform cryptographic hashing services in accordance
    ### with a specified cryptographic algorithm SHA-1 and [selection]
    ###         - SHA-256
    ###         - SHA-384
    ###         - SHA-512
    ###         - no other algorithm

    ### and message digest sizes 160 bits and [selection]
    ###         - 256 bits
    ###         - 384 bits
    ###         - 512 bits
    ###         - no other sizes

    ### that meet the following: FIPS Pub 180-4


    ### FCP_COP.1.1(3): https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_COP.1.1(3)
    ### The OS shall perform cryptographic signature services (generation
    ### and verification) in accordance with a specified algorithm


    ### FCP_COP.1.1(4): https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_COP.1.1(4)
    ### The OS shall perform keyed-hash message authentication services in
    ### accordance with a specified cryptographic algorithm [selection]
    ###     - SHA-1
    ###     - SHA-256
    ###     - SHA-384
    ###     - SHA-512

    ### with key size (in bits) used in HMAC

    ### and message digest sizes [selection]
    ###     - 160 bits
    ###     - 256 bits
    ###     - 384 bits
    ###     - 512 bits

    #######################################################
    ## FCS_RBG_EXT.1 Random Bit Generation

    ### FCS_RBG_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_RBG_EXT.1.1
    ### The OS shall perform all deterministic random bit generation (DRBG)
    ### services in accordance with NIST Special Publication 800-90A using
    ### [selection]
    ###     - HASH_DRBG (any),
    ###     - HMAC_DRBG (any),
    ###     - CTR_DRBG (AES)


    ### FCS_RBG_EXT.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_RBG_EXT.1.2
    ### The deterministic RBG used by the OS shall be seeded by an entropy source
    ### that accumulates entropy from a [selection]
    ###     - software-based noise source,
    ###     - platform-based noise source

    ### with a minimum of [selection]
    ###     - 128 bits
    ###     - 256 bits
    ### of entropy at least equal to the greatest strength (according to NIST
    ### 800-57) of the keys and hashes that it will generate.

    #######################################################
    ## FCS_STO_EXT.1 Storage of Sensitive Data

    ### FCS_STO_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_STO_EXT.1.1
    ### The OS shall implement functionality to encrypt sensitive data stored
    ### in non-volatile storage and provide interfaces to applications to
    ### invoke this functionality

    #######################################################
    ## FCS_TLSC_EXT.1 TLS Client Protocol

    ### FCS_TLSC_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.1.1
    ### The OS shall implement TLS 1.2 (RFC 5246) supporting the following
    ### cipher suites: [selection:
    ###     - TLS_RSA_WITH_AES_128_CBC_SHA as defined in RFC 5246,
    ###     - TLS_RSA_WITH_AES_128_CBC_SHA256 as defined in RFC 5246,
    ###     - TLS_RSA_WITH_AES_256_CBC_SHA256 as defined in RFC 5246,
    ###     - TLS_RSA_WITH_AES_256_CBC_SHA384 as defined in RFC 5288,
    ###     - TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 as defined in RFC 5246,
    ###     - TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 as defined in RFC 5246,
    ###     - TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 as defined in RFC 5288,
    ###     - TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 as defined in RFC 5289,
    ###     - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 as defined in RFC 5289,
    ###     - TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 as defined in RFC 5289,
    ###     - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 as defined in RFC 5289,
    ###     - TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 as defined in RFC 5289,
    ###     - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 as defined in RFC 5289,
    ###     - TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 as defined in RFC 5289,
    ###     - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 as defined in RFC 5289


    ### FCS_TLSC_EXT.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.1.2
    ### The OS shall verify that the presented identifier matches the reference
    ### identifier according to RFC 6125


    ### FCS_TLSC_EXT.1.3: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.1.3
    ### The OS shall only establish a trusted channel of the peer certificate is valid


    #######################################################
    # 5.1.2 User Data Protection (FDP)

    #######################################################
    ## FDP_ACF_EXT.1 Access Controlls for Protecting User Data

    ### FDP_ACF_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FDP_ACF_EXT.1.1
    ### The OS shall implement access controls which can prohibit
    ### unprivileged users from accessing files and directories
    ### owned by other users

    #######################################################
    # 5.1.3 Security Management (FMT)

    #######################################################
    ## FMT_MOF_EXT.1 Management of security functions behavior

    ### FMT_MOF_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FMT_MOF_EXT.1.1
    ### The OS shall restrict the ability to perform the function
    ### indicated in the "Administrator" column in FMT_SMF_EXT.1.1 to
    ### the administrator

    #### enable/disable screen lock

    #### enable/disable session timeout

    #### configure screen lock inactivity timeout

    #### configure session inactivity timeout
    - dconf_gnome_disable_user_admin


    #######################################################
    ## FMT_SMF_EXT.1 Specification of Management Functions

    ### FMT_SMF_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FMT_SMF_EXT.1.1
    ### The OS shall be capable of performing the following
    ### management functions:

    ### NOTE: rules below are from the NIAP Configuration Annex at
    ### https://www.niap-ccevs.org/MMO/PP/424.CANX/

    ### FMT_MOF_EXT.1 / IA-5(1)(a)
    ### Configure Minimum Password Length to 12 Characters
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen
    - accounts_password_minlen_login_defs

    ### FMT_MOF_EXT.1 / IA-5(1)(a)
    ### Require at Least 1 Special Character in Password
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ### FMT_MOF_EXT.1 / IA-5(1)(a)
    ### Require at Least 1 Numeric Character in Password
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ### FMT_MOF_EXT.1 / IA-5(1)(a)
    ### Require at Least 1 Uppercase Character in Password
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ### FMT_MOF_EXT.1 / IA-5(1)(a)
    ### Require at Least 1 Lowercase Character in Password
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ### FMT_MOF_EXT.1 / AC-11(a)
    ### Enable Screen Lock
    - package_tmux_installed
    # - dconf_use_text_backend
    - dconf_gnome_screensaver_idle_activation_enabled
    - dconf_gnome_screensaver_idle_delay
    - dconf_gnome_screensaver_lock_delay
    - dconf_gnome_screensaver_lock_enabled
    - dconf_gnome_screensaver_mode_blank
    - dconf_gnome_screensaver_user_info
    - dconf_gnome_screensaver_user_locks
    - dconf_gnome_session_idle_user_locks
    - configure_tmux_lock_command

    ### FMT_MOF_EXT.1 / AC-11(a)
    ### Set Screen Lock Timeout Period to 10 Minutes or Less
    - accounts_tmout
    - var_accounts_tmout=10_min

    ### FIA_AFL.1
    ### Disable Unauthenticated Login (such as Guest Accounts)
    - no_empty_passwords
    - grub2_password
    - grub2_uefi_password
    - grub2_disable_interactive_boot
    - require_singleuser_auth
    - service_debug-shell_disabled
    - sshd_disable_empty_passwords
    - sshd_disable_root_login
    - gnome_gdm_disable_automatic_login
    - gnome_gdm_disable_guest_login
    - sssd_offline_cred_expiration
    - sssd_memcache_timeout
    - var_sssd_memcache_timeout=1_day
    - disable_host_auth
    - sshd_disable_gssapi_auth
    - sshd_disable_kerb_auth
    - sshd_disable_rhosts_rsa
    - sshd_disable_rhosts
    - sshd_disable_user_known_hosts

    ### FMT_MOF_EXT.1 / AC-7(a)
    ### Set Maximum Number of Authentication Failures to
    ### 3 within 15 minutes
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - var_password_pam_retry=3
    - accounts_password_pam_retry
    - accounts_passwords_pam_faillock_deny_root
    - accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_interval
    - accounts_passwords_pam_faillock_unlock_time
    - dconf_gnome_login_retries

    ### FMT_MOF_EXT.1 / SC-7(12)
    ### Enable Host-Based Firewall
    - service_firewalld_enabled
    - set_firewalld_default_zone


    ### FMT_MOF_EXT.1 / CM-3(3)
    ### Configure Name/Address of Remote Management
    ### Server From Which to Receive Config Settings


    ### FAU_GEN.1.1.c / AU-4(1)
    ### Configure the System to Offload Audit Records to a Log Server
    - rsyslog_remote_loghost
    - auditd_audispd_syslog_plugin_activated
    - auditd_audispd_configure_remote_server
    - auditd_audispd_encrypt_sent_records    

    ### FMT_MOF_EXT.1 / AC-8(a)
    ### Set Logon Warning Banner
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text
    - banner_etc_issue
    - sshd_enable_warning_banner
    - login_banner_text=usgcb_default

    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit All Logons (Success/Failure)
    ### and Logoffs (Successful)


    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit File and Object Events (Unsuccessful)

    #### CREATE (Unsuccessful)
    - audit_rules_unsuccessful_file_modification_creat

    #### ACCESS (Unsuccessful)
    - audit_rules_unsuccessful_file_modification_openat_o_creat
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_openat_rule_order
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_rule_order
    - audit_rules_unsuccessful_file_modification_open_o_creat
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_open_rule_order

    #### DELETE (Unsuccessful)
    - audit_rules_unsuccessful_file_modification_unlink
    - audit_rules_unsuccessful_file_modification_unlinkat
 #   - audit_rules_file_deletion_events_renameat
 #   - audit_rules_file_deletion_events_rename
 #   - audit_rules_file_deletion_events_rmdir
 #   - audit_rules_file_deletion_events_unlinkat
 #   - audit_rules_file_deletion_events_unlink

    #### MODIFY (Unsuccessful)
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_rename
    - audit_rules_unsuccessful_file_modification_renameat
#   - audit_rules_privileged_commands_passwd
#    - audit_rules_privileged_commands_unix_chkpwd
#    - audit_rules_privileged_commands_userhelper
#    - audit_rules_privileged_commands_usernetctl
#    - audit_rules_privileged_commands_chage
#    - audit_rules_privileged_commands_chsh
#    - audit_rules_privileged_commands_pt_chown

    #### PERMISSION MODIFICATION (Unsuccessful)
#    - audit_rules_dac_modification_chmod
#    - audit_rules_dac_modification_fchmodat
#    - audit_rules_dac_modification_fchmod
#    - audit_rules_dac_modification_fremovexattr
#    - audit_rules_dac_modification_fsetxattr
#    - audit_rules_dac_modification_lremovexattr
#    - audit_rules_dac_modification_lsetxattr
#    - audit_rules_dac_modification_removexattr
#    - audit_rules_dac_modification_setxattr
#    - audit_rules_execution_chcon
#    - audit_rules_execution_restorecon
#    - audit_rules_execution_semanage
#    - audit_rules_execution_seunshare
#    - audit_rules_execution_setsebool
#    - audit_rules_mac_modification


    #### OWNERSHIP MODIFICATION (Unsuccessful)
    - audit_rules_unsuccessful_file_modification_chown
    - audit_rules_unsuccessful_file_modification_fchownat
    - audit_rules_unsuccessful_file_modification_fchown
    - audit_rules_unsuccessful_file_modification_lchown
#    - audit_rules_dac_modification_chown
#    - audit_rules_dac_modification_fchownat
#    - audit_rules_dac_modification_fchown
#    - audit_rules_dac_modification_lchown



    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit User and Group Management Events (Success/Failure)

    #### USER ADD (Success/Failure)


    #### USER DELETE (Success/Failure)


    #### USER MODIFY (Success/Failure)
    - audit_rules_usergroup_modification_passwd
    - audit_rules_usergroup_modification_shadow
    - audit_rules_etc_shadow_open
    - audit_rules_etc_shadow_openat
    - audit_rules_etc_shadow_open_by_handle_at
    - audit_rules_etc_passwd_open
    - audit_rules_etc_passwd_openat
    - audit_rules_etc_passwd_open_by_handle_at

    #### USER DISABLE (Success/Failure)


    #### USER ENABLE (Success/Failure)


    #### GROUP/ROLE ADD (Succes/Failure)
    - audit_rules_privileged_commands_newgidmap
    - audit_rules_privileged_commands_newgrp
    - audit_rules_privileged_commands_newuidmap

    ##### GROUP/ROLE DELETE (Success/Failure)


    ##### GROUP/ROLE MODIFY (Success/Failure)
    - audit_rules_privileged_commands_gpasswd
    - audit_rules_usergroup_modification_group
    - audit_rules_usergroup_modification_gshadow
    - audit_rules_etc_gshadow_open
    - audit_rules_etc_gshadow_openat
    - audit_rules_etc_gshadow_open_by_handle_at
    - audit_rules_usergroup_modification_opasswd
    - audit_rules_etc_group_open
    - audit_rules_etc_group_openat
    - audit_rules_etc_group_open_by_handle_at

    - audit_rules_privileged_commands_sudoedit



    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit Privilege and Role Escalation Events (Success/Failure)
    - audit_rules_privileged_commands_sudo
    - audit_rules_privileged_commands_su

    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit All Audit and Log Data Accesses (Success/Failure)
    - audit_rules_login_events_faillock
    - audit_rules_login_events_lastlog
    - audit_rules_login_events_tallylog
    - directory_access_var_log_audit

    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit Cryptographic Verification of Software (Success/Failure)


    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit Program Initiations (Success/Failure)


    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit System Reboot, Restart, and Shutdown
    ### Events (Success/Failure)


    ### FAU_GEN.1.1.c / AU-2(a)
    ### Audit Kernel Module Loading and Unloading Events (Success/Failure)
    - audit_rules_kernel_module_loading_delete
    - audit_rules_kernel_module_loading_init

    ### FMT_MOF_EXT.1 / SI-2
    ### Enable Automatic Software Update


    #######################################################
    # 5.1.4 Protection of the TSF (FPT)

    #######################################################
    ## FPT_ACF_EXT.1 Access Controls

    ### FPT_ACF_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_ACF_EXT.1.1
    ### The OS shall implement access controls which prohibit
    ### unprivileged users from modifying:
    ###     - kernel and its drivers/modules
    ###     - security audit logs
    ###     - shared libraries
    ###     - system executables
    ###     - system configuration files
    ###     - [assignment: other objects]

    ### FPT_ACF_EXT.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_ACF_EXT.1.2
    ### The OS shall implement access controls which prohibit
    ### unprivileged users from reading:
    ###     - security audit logs
    ###     - system-wide credential repositories
    ###     - [assignment: list of other objects]

    #######################################################
    ## FPT_ASLR_EXT.1 Address Space Layout Randomization

    ### FPT_ASLR_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_ASLR_EXT.1.1
    ### The OS shall always randomize address space memory locations
    ### with [selection: 8, [assignment: number greater than 8]] bits of
    ### entropy except for [assignment: list of explicity exceptions]

    #######################################################
    ## FPT_SBOP_EXT.1 Stack Buffer Overflow Protection

    ### FPT_SBOP_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_SBOP_EXT.1.1
    ### The OS shall [selection: employ stack-based buffer overflow protections,
    ### not store parameters/variables in the same data structures as control
    ### flow values].

    #######################################################
    ## FPT_TST_EXT.1 Boot Integrity

    ### FPT_TST_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_TST_EXT.1.1
    ### The OS shall verify the integrity of the bootchain up through
    ### the OS kernel and [selection:
    ###     - all executable code stored in mutable media,
    ###     - [assignment: list of other executable code],
    ###     - no other executable code
    ###
    ### ] prior to its execution through the use of [selection:
    ###     - a digital signature using a hardware-protected
    ###       asymetric key,
    ###     - a hardware-protected hash]

    #######################################################
    ## FPT_TUD_EXT.1 Trusted Update

    ### FPT_TUD_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_TUD_EXT.1.1
    ### The OS shall provide the ability to check for updates
    ### to the OS software itself.
    # - security_patches_up_to_date  # Not available on Fedora

    ### FPT_TUD_EXT.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_TUD_EXT.1.2
    ### The OS shall cryptographically verify updates to itself using
    ### a digital signature prior to installation using schemes specified
    ### in FCS_COP.1(3).

    #######################################################
    ## FPT_TUD_EXT.2 Trusted Update for Application Software

    ### FPT_TUD_EXT.2.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_TUD_EXT.2.1
    ### The OS shall provide the ability to check for updates to
    ### application software

    ### FPT_TUD_EXT.2.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_TUD_EXT.2.2
    ### The OS shall cryptographically verify the integrity of updates
    ### to applications using a digital signature specified by FCS_COP.1(3)
    ### prior to installation.


    #######################################################
    # 5.1.5 Audit Data Generation (FAU)

    #######################################################
    ## FAU_GEN.1 Audit Data Generation (Refined)

    ### FAU_GEN.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FAU_GEN.1.1
    ### The OS shall be able to generate an audit record
    ### of the following auditable events:
    ###
    ### RESPONSE: This requirement regards capability,
    ###           no configuration action needed.

    ### FAU_GEN.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FAU_GEN.1.2
    ### The OS shall record within each audit record at least
    ### the following information:
    ###
    ###     a. Date and time of the event, type of event, subject
    ###        identity (if applicable), and outcome (success or failure)
    ###        of the event; and
    ###     b. For each audit event type, based on the auditable event
    ###        definitions of the functional components included in the
    ###        PP/ST, [assignment: other audit relevant information]

    #######################################################
    # 5.1.6 Identification and Authentication (FIA)

    #######################################################
    ## FIA_AFL.1 Authentication failure handling (Refined)

    ### FIA_AFL.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_AFL.1.1
    ### The OS shall detet when [selection:
    ###     - [assignment: positive integer number],
    ###     - an administrator configurable positive integer within
    ###       [assignment: range of acceptable values]
    ### ] unsuccessful authentication attempts occur related to
    ### events with [selection:
    ###     - authentication based on user name and password,
    ###     - authentication based on user name and a PIN that releases
    ###       an asymmetric key stored in OE-protected storage,
    ###     - authentication based on X.509 certificates
    ### ]

    ### FIA_AFL.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_AFL.1.2
    ### When the defined number of unsuccesful authentication attempts
    ### for an account has been met, the OS shall: [selection:
    ### Account Lockout, Account Disablement, Mandatory Credential Reset,
    ### [assignment: list of actions]].

    #######################################################
    ## FIA_UAU.5 Multiple Authentication Mechanisms (Refined)

    ### FIA_UAU.5.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_UAU.5.1
    ### The OS shall provide the following authentication mechanisms
    ### [selection:
    ###     - authentication based on user name and password,
    ###     - authentication based on user name and a PIN that releases
    ###       an asymmetric key stored in OE-protected storage,
    ###     - authentication based on X.509 certificates,
    ###     - for use in SSH only, SSH public key-based authentication
    ###       as specified by the EP.for Secure Shell
    ### ] to support user authentication.

    ### FIA_UAU.5.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_UAU.5.2
    ### The OS shall authenticate any user's claimed identity according to
    ### [assignment: rules describing how the multiple authentication
    ### mechanisms provide authentication].

    #######################################################
    ## FIA_X509_EXT.1 X.509 Certificate Validation

    ### FIA_X509_EXT.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_X509_EXT.1.1
    ### The OS shall implement functionality to validate certificates
    ### in accordance with the following rules:
    ###     - RFC 5280 certificate validation and certificate path validation
    ###     - The certificate path must terminate with a trusted CA certificate
    ###     - The OS shall validate a certificate path by ensuring the presense
    ###       of the basicConstraints extension and that the CA flag is set to
    ###       TRUE for all CA certificates
    ###     - The OS shall validate the revocation status of the certificate
    ###       using [selection: the Online Certificate Status Protocol (OSCP)
    ###       as specified RFC 2560, a Certificate Revocation List (CRL) as
    ###       specified in RFC 5759, an OCSP TLS Status Request Extension
    ###       (i.e., OSCP stapling) as specified in RFC 6066].
    ###     - The OS shall validate the extendedKeyUsage field according to the
    ###       following rules:
    ###         * Certificates used for trusted updates and executable code
    ###           integrity verification shall have the Code Signing purpose
    ###           (id-kp 3 with OID 1.3.6.1.5.5.7.3.3) in the extendedKeyUsage
    ###           field.
    ###         * Server certificates presented for TLS shall have the Server
    ###           Authentication purpose (id-kp 1 with OID 1.3.6.1.5.5.7.3.1)
    ###           in the extendedKeyUsage field.
    ###         * Client certificates presented for TLS shall have the Client
    ###           Authentication purpose (id-kp 2 with OID 1.3.6.1.5.5.7.3.2) in the
    ###           extendedKeyUsage field.
    ###         * S/MIME certificates presented for email encryption and signature
    ###           shall have the Email Protection purpose (id-kp 4 with OID
    ###           1.3.6.1.5.5.7.3.4) in the extendedKeyUsage field.
    ###         * OCSP certificates presented for OCSP responses shall have the OCSP
    ###           Signing purpose (id-kp 9 with OID 1.3.6.1.5.5.7.3.9) in the
    ###           extendedKeyUsage field.
    ###         * (Conditional) Server certificates presented for EST shall have the
    ###           CMC Registration Authority (RA) purpose (id-kp-cmcRA with OID
    ###           1.3.6.1.5.5.7.3.28) in the extendedKeyUsage field.

    #######################################################
    ## FIA_X509_EXT.2 X.509 Certificate Authentication

    ### FIA_X509_EXT.2.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FIA_X509_EXT.2.1
    ### The OS shall use X.509v3 certificates as defined by RFC 5280 to
    ### support authentication for TLS and [selection: DTLS, HTTPS, [assignment:
    ### other protocols], no other protocols] connections.

    #######################################################
    # 5.1.7 Trusted Path/Channels (FTP)

    #######################################################
    ## FTP_ITC_EXT.1 Trusted channel communication

    ### FTP_ITC_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FTP_ITC_EXT.1.1
    ### The OS shall use [selection:
    ###     - TLS as conforming to FCS_TLSC_EXT.1,
    ###     - DTLS as conforming to FCS_DTLS_EXT.1,
    ###     - IPsec as conforming to the EP for IPsec VPN Clients,
    ###     - SSH as conforming to EP for Secure Shell
    ### ] to provide a trusted communication channel between itself and authorized
    ### IT entities supporting the following capabilities: [sekection: audit server,
    ### authentication server, management server, [assignment: other capabilities]]
    ### that is logically distinct from other communication channels and provides
    ### assured identification of its end points and protection of the channel data
    ### from disclosure and detection of modification of the channel data.

    #######################################################
    ## FTP_TRP.1 Trusted Path

    ### FTP_TRP.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FTP_TRP.1.1
    ### The OS shall provide a communication path between itself and
    ### [selection: remote, local] users that is logically distinct from other
    ### communication paths and provides assured identification of its endpoints
    ### and protection of the communicated data from modification and disclosure.


    ### FTP_TRP.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FTP_TRP.1.2
    ### The OS shall permid [selection: the TSF, local users, remote users]
    ### to initiate communication via the trusted path.


    ### FTP_TRP.1.3: https://www.niap-ccevs.org/MMO/PP/-424-/#FTP_TRP.1.3
    ### The OS shall require use of the trusted path for all remote
    ### administrative actions.

    #######################################################
    # 5.2.3 Class AGD: Guidance Documentation

    #######################################################
    ## Content and presentation elements

    ### AGD_PRE.1.2C: https://www.niap-ccevs.org/MMO/PP/-424-/#AGD_PRE.1.2C
    ### The preparative procedures shall describe all the steps necessary
    ### for secure installation of the OS and for all the secure preparation
    ### of the operational environment in accordance with the security
    ### objectives for the operational environment as described in the ST
    - installed_OS_is_vendor_supported
    - installed_OS_is_FIPS_certified
    - grub2_audit_argument
    - grub2_audit_backlog_limit_argument
    - service_auditd_enabled
    # - rpm_verify_hashes  # Takes too long to complete
    - selinux_all_devicefiles_labeled
    - selinux_confinement_of_daemons
    - selinux_policytype
    - selinux_state
    - audit_rules_immutable
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
    # - ensure_redhat_gpgkey_installed  # Not available on Fedora
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - ensure_gpgcheck_local_packages

    #######################################################
    # Appendix A Optional Requirements

    #######################################################
    ## FCS_TLSC_EXT.4 TLS Client Protocol

    ### FCS_TLSC_EXT.4.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.4.1
    ### The OS shall support mutual authentication using X.509v3 certificates

    #######################################################
    ## FDP_IFC_EXT.1 Information flow control

    ### FDP_IFC_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FDP_IFC_EXT.1.1
    ### The OS shall [selection:
    ###     - provide an interface which allows a VPN client to protect
    ###       all IP traffic using IPsec,
    ###     - provide a VPN client which can protects all IP traffic
    ###       using IPsec
    ### ] with the exception of IP traffic required to establish the VPN connection
    ### and [selection: signed updates directly from the OS vendor, no other
    ### traffic]

    #######################################################
    ## FTA_TAB.1 Default TOE access banners

    ### FTA_TAB.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FTA_TAB.1.1
    ### Before establishing a user session, the OS shall display an
    ### advisory warning message regarding unauthorized use of the OS.


    #######################################################
    # Appendix B Selection-Based Requirements

    #######################################################
    ## FCS_DTLS_EXT.1 DTLS Implementation

    ### FCS_DTLS_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_DTLS_EXT.1.1
    ### The OS shall implement the DTLS protocol in accordance with
    ### [selection: DTLS 1.0 (RFC 4347), DTLS 1.2 (RFC 6347)].


    ### FCS_DTLS_EXT.1.2: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_DTLS_EXT.1.2
    ### The OS shall implement the requirements in TLS (FCS_TLSC_EXT.1) for the DTLS
    ### implementation, except where variations are allowed according to DTLS
    ### 1.2 (RFC 6347).

    #######################################################
    ## FCS_TLSC_EXT.2 TLS Client Protocol

    ### FCS_TLSC_EXT.2.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.2.1
    ### The OS shall present the Supported Elliptical Curves Extension in the Client
    ### Hello with the following NIST curves: [selection: secp256r1, secp384r1,
    ### secp521r1].


    #######################################################
    # Appendix C Objective Requirements

    #######################################################
    ## FCS_TLSC_EXT.3 TLS Client Protocol

    ### FCS_TLSC_EXT.3.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FCS_TLSC_EXT.3.1
    ### The OS shall present the signature_algorithms extension in the Client Hello
    ### with the supported_signature_algorithms value containing the following hash
    ### algorithms: [selection: SHA256, SHA384, SHA512] and no other hash algorithms.


    #######################################################
    ## FPT_SRP_EXT.1 Software Restriction Policies

    ### FPT_SRP_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_SRP_EXT.1.1
    ### The OS shall restrict execution to only programs which match an
    ### administrator-specified [selection:
    ###     - file path,
    ###     - file digital signature,
    ###     - version,
    ###     - hash,
    ###     - [assignment: other characteristics]]


    #######################################################
    ## FPT_W^X_EXT.1 Write XOR Execute Memory Pages

    ### FPT_W^X_EXT.1.1: https://www.niap-ccevs.org/MMO/PP/-424-/#FPT_W^X_EXT.1.1
    ### The OS shall prevent allocation of any memory region with both write
    ### and execute permissions except for [assignment: list of exceptions]









    #######################################################
    ## Rules that need a home?

    - enable_fips_mode
    - sysctl_kernel_yama_ptrace_scope
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_kexec_load_disabled
    - sysctl_kernel_dmesg_restrict
    - grub2_slub_debug_argument
    - grub2_page_poison_argument
    - grub2_vsyscall_argument

    - audit_rules_privileged_commands_at
    - audit_rules_privileged_commands_crontab
    - audit_rules_privileged_commands_mount
    - audit_rules_privileged_commands_umount
    - audit_rules_sysadmin_actions
    - audit_rules_session_events

    - audit_rules_privileged_commands_ssh_keysign
    - rsyslog_cron_logging
    - mount_option_dev_shm_nodev
    - mount_option_dev_shm_noexec
    - mount_option_dev_shm_nosuid
    - package_abrt_removed

    - var_system_crypto_policy=fips
    - configure_crypto_policy
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_ssh_crypto_policy
    - configure_kerberos_crypto_policy
