documentation_complete: true

title: 'DISA STIG for SUSE Linux Enterprise 12'

description: "This profile contains configuration checks that align to the \n
    \ DISA STIG for SUSE Linux Enterprise 12."

selections:
     - installed_OS_is_certified
     - account_temp_expire_date
     - account_disable_post_pw_expiration
     - var_account_disable_post_pw_expiration=35
     - package_aide_installed
     - ensure_gpgcheck_globally_activated
     - gui_login_dod_acknowledgement
     - banner_etc_motd
     - dconf_gnome_banner_enabled
     - vlock_installed
     - accounts_tmout
     - sudo_remove_no_authenticate
     - sudo_remove_nopasswd
     - var_accounts_max_concurrent_login_sessions=10
     - accounts_max_concurrent_login_sessions
     - accounts_passwords_pam_tally2
     - var_accounts_fail_delay=4
     - accounts_logon_fail_delay
     - cracklib_accounts_password_pam_ucredit
     - cracklib_accounts_password_pam_lcredit
     - cracklib_accounts_password_pam_dcredit
     - cracklib_accounts_password_pam_ocredit
     - cracklib_accounts_password_pam_difok
     - set_password_hashing_algorithm_systemauth
     - set_password_hashing_algorithm_logindefs
     - accounts_password_all_shadowed_sha512
     - no_empty_passwords
     - set_password_hashing_min_rounds_logindefs
     - var_password_pam_minlen=15
     - cracklib_accounts_password_pam_minlen
     - var_accounts_minimum_age_login_defs=1
     - accounts_minimum_age_login_defs
     - account_minimum_age_shadow
     - var_accounts_maximum_age_login_defs=60
     - accounts_maximum_age_login_defs
     - account_maximum_age_shadow
     - file_etc_security_opasswd
     - var_password_pam_unix_remember=5
     - accounts_password_pam_unix_remember
     - faildelay
     - gnome_gdm_disable_automatic_login
     - display_login_attempts
     - package_openssh_installed
     - sshd_enable_warning_banner
     - sshd_set_loglevel_verbose
     - sshd_print_last_log
     - sshd_disable_root_login
     - sshd_disable_empty_passwords
     - sshd_do_not_permit_user_env
     - no_user_host_based_files
     - no_host_based_files
     - var_system_crypto_policy=fips
     - enable_fips_mode

