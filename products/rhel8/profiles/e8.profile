documentation_complete: true

metadata:
    SMEs:
        - shaneboulden

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers 

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 8
  that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

  A copy of the Essential Eight in Linux Environments guide can be found at the
  ACSC website:

  https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:

  ### Remove obsolete packages
  - package_talk_removed
  - package_talk-server_removed
  - package_xinetd_removed
  - service_xinetd_disabled
  - package_ypbind_removed
  - package_telnet_removed
  - service_telnet_disabled
  - package_telnet-server_removed
  - package_rsh_removed
  - package_rsh-server_removed
  - service_zebra_disabled
  - package_quagga_removed
  - service_avahi-daemon_disabled
  - package_squid_removed
  - service_squid_disabled

  ### Software update
  - ensure_redhat_gpgkey_installed
  - ensure_gpgcheck_never_disabled
  - ensure_gpgcheck_local_packages
  - ensure_gpgcheck_globally_activated
  - security_patches_up_to_date
  - dnf-automatic_security_updates_only

  ### System security settings
  - sysctl_kernel_randomize_va_space
  - sysctl_kernel_exec_shield
  - sysctl_kernel_kptr_restrict
  - sysctl_kernel_dmesg_restrict
  - sysctl_kernel_kexec_load_disabled
  - sysctl_kernel_yama_ptrace_scope
  - sysctl_kernel_unprivileged_bpf_disabled
  - sysctl_net_core_bpf_jit_harden

  ### SELinux
  - var_selinux_state=enforcing
  - selinux_state
  - var_selinux_policy_name=targeted
  - selinux_policytype

  ### Filesystem integrity
  - rpm_verify_hashes
  - rpm_verify_permissions
  - rpm_verify_ownership
  - file_permissions_unauthorized_sgid
  - file_permissions_unauthorized_suid
  - file_permissions_unauthorized_world_writable
  - dir_perms_world_writable_sticky_bits
  - file_permissions_library_dirs
  - file_ownership_binary_dirs
  - file_permissions_binary_dirs
  - file_ownership_library_dirs

  ### Passwords
  - no_empty_passwords

  ### Partitioning
  - mount_option_dev_shm_nodev
  - mount_option_dev_shm_nosuid
  - mount_option_dev_shm_noexec

  ### Network
  - package_firewalld_installed
  - service_firewalld_enabled
  - network_sniffer_disabled

  ### Admin privileges
  - accounts_no_uid_except_zero
  - sudo_remove_nopasswd
  - sudo_remove_no_authenticate
  - sudo_require_authentication

  ### Audit
  - package_rsyslog_installed
  - service_rsyslog_enabled
  - service_auditd_enabled
  - var_auditd_flush=incremental_async
  - auditd_data_retention_flush
  - auditd_local_events
  - auditd_write_logs
  - auditd_log_format
  - auditd_freq
  - auditd_name_format
  - audit_rules_login_events_tallylog
  - audit_rules_login_events_faillock
  - audit_rules_login_events_lastlog
  - audit_rules_login_events
  - audit_rules_time_adjtimex
  - audit_rules_time_clock_settime
  - audit_rules_time_watch_localtime
  - audit_rules_time_settimeofday
  - audit_rules_time_stime
  - audit_rules_execution_restorecon
  - audit_rules_execution_chcon
  - audit_rules_execution_semanage
  - audit_rules_execution_setsebool
  - audit_rules_execution_setfiles
  - audit_rules_execution_seunshare
  - audit_rules_sysadmin_actions
  - audit_rules_networkconfig_modification
  - audit_rules_usergroup_modification
  - audit_rules_dac_modification_chmod
  - audit_rules_dac_modification_chown
  - audit_rules_kernel_module_loading

  ### Secure access
  - sshd_disable_root_login
  - sshd_disable_gssapi_auth
  - sshd_print_last_log
  - sshd_do_not_permit_user_env
  - sshd_disable_rhosts
  - sshd_set_loglevel_info
  - sshd_disable_empty_passwords
  - sshd_disable_user_known_hosts
  - sshd_enable_strictmodes

  # See also: https://www.cyber.gov.au/acsc/view-all-content/guidance/asd-approved-cryptographic-algorithms
  - var_system_crypto_policy=default_nosha1
  - configure_crypto_policy
  - configure_ssh_crypto_policy

  ### Application whitelisting
  - package_fapolicyd_installed
  - service_fapolicyd_enabled

  ### Backup
  - package_rear_installed
