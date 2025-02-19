description: 'This draft profile contains configuration checks for Red Hat Enterprise
    Linux 10

    that align to the Australian Cyber Security Centre (ACSC) Information Security
    Manual (ISM).


    The ISM uses a risk-based approach to cyber security. This profile provides a
    guide to aligning

    Red Hat Enterprise Linux security controls with the ISM, which can be used to
    select controls

    specific to an organisation''s security posture and risk profile.


    A copy of the ISM can be found at the ACSC website:


    https://www.cyber.gov.au/ism'
extends: null
hidden: ''
status: ''
metadata:
    SMEs:
    - shaneboulden
    - wcushen
    - eliseelk
    - sashperso
    - anjuskantha
reference: https://www.cyber.gov.au/ism
selections:
- accounts_maximum_age_login_defs
- accounts_minimum_age_login_defs
- accounts_no_uid_except_zero
- accounts_password_minlen_login_defs
- accounts_password_pam_dcredit
- accounts_password_pam_lcredit
- accounts_password_pam_minclass
- accounts_password_pam_minlen
- accounts_password_pam_ocredit
- accounts_password_pam_ucredit
- accounts_password_warn_age_login_defs
- accounts_passwords_pam_faillock_deny
- accounts_passwords_pam_faillock_deny_root
- accounts_passwords_pam_faillock_interval
- accounts_passwords_pam_faillock_unlock_time
- audit_access_failed
- audit_access_failed_aarch64
- audit_access_failed_ppc64le
- audit_access_success
- audit_access_success_aarch64
- audit_access_success_ppc64le
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
- audit_rules_networkconfig_modification
- audit_rules_privileged_commands
- audit_rules_session_events
- audit_rules_sysadmin_actions
- audit_rules_time_adjtimex
- audit_rules_time_clock_settime
- audit_rules_time_settimeofday
- audit_rules_time_stime
- audit_rules_time_watch_localtime
- audit_rules_unsuccessful_file_modification
- auditd_data_retention_flush
- auditd_freq
- auditd_local_events
- auditd_log_format
- auditd_name_format
- auditd_write_logs
- chronyd_configure_pool_and_server
- chronyd_or_ntpd_specify_multiple_servers
- chronyd_specify_remote_server
- configure_crypto_policy
- configure_firewalld_ports
- configure_kerberos_crypto_policy
- configure_opensc_card_drivers
- configure_ssh_crypto_policy
- dir_perms_world_writable_sticky_bits
- disable_host_auth
- dnf-automatic_apply_updates
- dnf-automatic_security_updates_only
- enable_authselect
- enable_fips_mode
- enable_ldap_client
- ensure_gpgcheck_globally_activated
- ensure_gpgcheck_local_packages
- ensure_gpgcheck_never_disabled
- ensure_redhat_gpgkey_installed
- file_ownership_binary_dirs
- file_ownership_library_dirs
- file_permissions_binary_dirs
- file_permissions_library_dirs
- file_permissions_sshd_private_key
- file_permissions_unauthorized_sgid
- file_permissions_unauthorized_suid
- file_permissions_unauthorized_world_writable
- kerberos_disable_no_keytab
- mount_option_dev_shm_nodev
- mount_option_dev_shm_noexec
- mount_option_dev_shm_nosuid
- network_ipv6_static_address
- network_nmcli_permissions
- network_sniffer_disabled
- no_empty_passwords
- no_shelllogin_for_systemaccounts
- package_aide_installed
- package_audit_installed
- package_chrony_installed
- package_fapolicyd_installed
- package_firewalld_installed
- package_libdnf-plugin-subscription-manager_installed
- package_opensc_installed
- package_pcsc-lite-ccid_installed
- package_pcsc-lite_installed
- package_rsyslog_installed
- package_squid_removed
- package_subscription-manager_installed
- package_sudo_installed
- package_telnet-server_removed
- package_telnet_removed
- package_usbguard_installed
- require_emergency_target_auth
- rsyslog_cron_logging
- rsyslog_files_groupownership
- rsyslog_files_ownership
- rsyslog_files_permissions
- rsyslog_nolisten
- rsyslog_remote_loghost
- rsyslog_remote_tls
- rsyslog_remote_tls_cacert
- sebool_auditadm_exec_content
- sebool_authlogin_nsswitch_use_ldap
- sebool_authlogin_radius
- sebool_kerberos_enabled
- selinux_policytype
- selinux_state
- service_auditd_enabled
- service_avahi-daemon_disabled
- service_chronyd_enabled
- service_fapolicyd_enabled
- service_firewalld_enabled
- service_pcscd_enabled
- service_rsyslog_enabled
- service_snmpd_disabled
- service_squid_disabled
- service_telnet_disabled
- service_usbguard_enabled
- set_firewalld_default_zone
- set_password_hashing_algorithm_libuserconf
- set_password_hashing_algorithm_logindefs
- set_password_hashing_algorithm_passwordauth
- set_password_hashing_algorithm_systemauth
- snmpd_use_newer_protocol
- sshd_disable_empty_passwords
- sshd_disable_gssapi_auth
- sshd_disable_kerb_auth
- sshd_disable_rhosts
- sshd_disable_root_login
- sshd_disable_user_known_hosts
- sshd_disable_x11_forwarding
- sshd_do_not_permit_user_env
- sshd_enable_strictmodes
- sshd_enable_warning_banner
- sshd_print_last_log
- sshd_set_loglevel_info
- sshd_set_max_auth_tries
- sshd_use_directory_configuration
- sssd_enable_smartcards
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
- system_booted_in_fips_mode
- wireless_disable_interfaces
- var_system_crypto_policy=fips
- var_auditd_flush=incremental_async
- var_selinux_state=enforcing
- var_selinux_policy_name=targeted
- var_authselect_profile=sssd
- sshd_max_auth_tries_value=5
- var_password_pam_minlen=14
- var_accounts_password_minlen_login_defs=14
- var_accounts_password_warn_age_login_defs=7
- var_accounts_minimum_age_login_defs=1
- var_accounts_maximum_age_login_defs=60
- var_password_hashing_algorithm_pam=yescrypt
unselected_groups: []
platforms: !!set {}
cpe_names: !!set {}
platform: null
filter_rules: ''
policies:
- ism_o
title: Australian Cyber Security Centre (ACSC) ISM Official - Base
documentation_complete: true
