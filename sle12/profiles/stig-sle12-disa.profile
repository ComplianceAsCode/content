documentation_complete: true

title: 'DISA STIG for SUSE Linux Enterprise 12'

description: "This profile contains configuration checks that align to the \n
    \ DISA STIG for SUSE Linux Enterprise 12."

selections:
     - installed_OS_is_certified
     - account_temp_expire_date
     - account_disable_post_pw_expiration
     - var_account_disable_post_pw_expiration=0
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

