documentation_complete: true

title: 'Basic Profile for Embedded Systems'

description: |-
    This profile contains items common to many embedded Linux installations.
    Regardless of your system's deployment objective, all of these checks should pass.

selections:
    - sshd_idle_timeout_value=10_minutes
    - var_accounts_fail_delay=4
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_unlock_time=604800
    - var_accounts_user_umask=077
    - var_auditd_action_mail_acct=root
    - var_auditd_max_log_file_action=rotate
    - var_auditd_num_logs=5
    - var_auditd_space_left_action=email
    - var_selinux_policy_name=targeted
    - accounts_logon_fail_delay
    - accounts_max_concurrent_login_sessions
    - accounts_no_uid_except_zero
    - accounts_password_all_shadowed
    - accounts_root_path_dirs_no_write
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile
    - file_permissions_home_dirs
    - no_empty_passwords
    - no_netrc_files
    - root_path_no_dot
