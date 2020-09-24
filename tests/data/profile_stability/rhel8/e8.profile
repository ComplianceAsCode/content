description: 'This profile contains configuration checks for Red Hat Enterprise Linux
    8

    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.


    A copy of the Essential Eight in Linux Environments guide can be found at the

    ACSC website:


    https://www.cyber.gov.au/publications/essential-eight-in-linux-environments'
documentation_complete: true
selections:
- accounts_no_uid_except_zero
- audit_rules_dac_modification_chmod
- audit_rules_dac_modification_chown
- audit_rules_execution_chcon
- audit_rules_execution_restorecon
- audit_rules_execution_semanage
- audit_rules_execution_setfiles
- audit_rules_execution_setsebool
- audit_rules_execution_seunshare
- audit_rules_kernel_module_loading
- audit_rules_login_events
- audit_rules_login_events_faillock
- audit_rules_login_events_lastlog
- audit_rules_login_events_tallylog
- audit_rules_networkconfig_modification
- audit_rules_sysadmin_actions
- audit_rules_time_adjtimex
- audit_rules_time_clock_settime
- audit_rules_time_settimeofday
- audit_rules_time_stime
- audit_rules_time_watch_localtime
- audit_rules_usergroup_modification
- auditd_data_retention_flush
- auditd_freq
- auditd_local_events
- auditd_log_format
- auditd_name_format
- auditd_write_logs
- configure_crypto_policy
- configure_ssh_crypto_policy
- dir_perms_world_writable_sticky_bits
- dnf-automatic_security_updates_only
- ensure_gpgcheck_globally_activated
- ensure_gpgcheck_local_packages
- ensure_gpgcheck_never_disabled
- ensure_redhat_gpgkey_installed
- file_ownership_binary_dirs
- file_ownership_library_dirs
- file_permissions_binary_dirs
- file_permissions_library_dirs
- file_permissions_unauthorized_sgid
- file_permissions_unauthorized_suid
- file_permissions_unauthorized_world_writable
- mount_option_dev_shm_nodev
- mount_option_dev_shm_noexec
- mount_option_dev_shm_nosuid
- network_sniffer_disabled
- no_empty_passwords
- package_fapolicyd_installed
- package_firewalld_installed
- package_quagga_removed
- package_rear_installed
- package_rsh-server_removed
- package_rsh_removed
- package_rsyslog_installed
- package_squid_removed
- package_talk-server_removed
- package_talk_removed
- package_telnet-server_removed
- package_telnet_removed
- package_xinetd_removed
- package_ypbind_removed
- rpm_verify_hashes
- rpm_verify_ownership
- rpm_verify_permissions
- security_patches_up_to_date
- selinux_policytype
- selinux_state
- service_auditd_enabled
- service_avahi-daemon_disabled
- service_fapolicyd_enabled
- service_firewalld_enabled
- service_rsyslog_enabled
- service_squid_disabled
- service_telnet_disabled
- service_xinetd_disabled
- service_zebra_disabled
- sshd_disable_empty_passwords
- sshd_disable_gssapi_auth
- sshd_disable_rhosts
- sshd_disable_root_login
- sshd_disable_user_known_hosts
- sshd_do_not_permit_user_env
- sshd_enable_strictmodes
- sshd_print_last_log
- sshd_set_loglevel_info
- sudo_remove_no_authenticate
- sudo_remove_nopasswd
- sudo_require_authentication
- sysctl_kernel_dmesg_restrict
- sysctl_kernel_exec_shield
- sysctl_kernel_kexec_load_disabled
- sysctl_kernel_kptr_restrict
- sysctl_kernel_randomize_va_space
- sysctl_kernel_unprivileged_bpf_disabled
- sysctl_kernel_yama_ptrace_scope
- sysctl_net_core_bpf_jit_harden
- var_selinux_state=enforcing
- var_selinux_policy_name=targeted
- var_auditd_flush=incremental_async
- var_system_crypto_policy=default_nosha1
title: Australian Cyber Security Centre (ACSC) Essential Eight
