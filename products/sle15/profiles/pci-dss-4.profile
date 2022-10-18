documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4 Control Baseline for SUSE Linux enterprise 15'

description: |-
    Ensures PCI-DSS v4 security configuration settings are applied.

selections:
    - pcidss_3:all:base
    - accounts_minimum_age_login_defs
    - accounts_no_uid_except_zero
    - accounts_password_warn_age_login_defs
    - accounts_tmout
    - accounts_umask_etc_bashrc
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
    - cracklib_accounts_password_pam_dcredit
    - cracklib_accounts_password_pam_lcredit
    - cracklib_accounts_password_pam_minlen
    - cracklib_accounts_password_pam_ocredit
    - cracklib_accounts_password_pam_retry
    - cracklib_accounts_password_pam_ucredit
    - file_permissions_sshd_private_key
    - file_permissions_sshd_pub_key
    - no_direct_root_logins
    - package_audit_installed
    - package_chrony_installed
    - package_openldap-clients_removed
    - package_sudo_installed
    - package_telnet-server_removed
    - package_vsftpd_removed
    - package_ypserv_removed
    - postfix_network_listening_disabled
    - securetty_root_login_console_only
    - sshd_disable_empty_passwords
    - sshd_disable_root_login
    - sshd_do_not_permit_user_env
    - sshd_enable_warning_banner
    - sshd_set_loglevel_verbose
    - sudo_add_use_pty
    - sudo_custom_logfile
    
