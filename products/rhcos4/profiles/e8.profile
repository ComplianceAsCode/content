documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This profile contains configuration checks for Red Hat Enterprise Linux CoreOS
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:

  ### System security settings
  - sysctl_kernel_randomize_va_space
  - sysctl_kernel_kptr_restrict
  - sysctl_kernel_dmesg_restrict
  - sysctl_kernel_yama_ptrace_scope
  - sysctl_kernel_unprivileged_bpf_disabled
  - sysctl_net_core_bpf_jit_harden

  ### SELinux
  - var_selinux_state=enforcing
  - selinux_state
  - var_selinux_policy_name=targeted
  - selinux_policytype

  ### Passwords
  - no_empty_passwords

  ### Admin privileges
  - accounts_no_uid_except_zero
  
  ### Audit
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
  - audit_rules_kernel_module_loading_delete
  - audit_rules_kernel_module_loading_finit
  - audit_rules_kernel_module_loading_init

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
