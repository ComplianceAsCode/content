documentation_complete: true

title: 'Canonical Ubuntu 20.04 LTS Security Technical Implementation Guide (STIG) V1R9'

description: |-
    This Security Technical Implementation Guide is published as a tool to
    improve the security of Department of Defense (DoD) information systems.
    The requirements are derived from the National Institute of Standards and
    Technology (NIST) 800-53 and related documents.

selections:
    # UBTU-20-010000 The Ubuntu operating system must provision temporary user accounts with an expiration time of 72 hours or less.
    - account_temp_expire_date

    # UBTU-20-010002 The Ubuntu operating system must enable the graphical user logon banner to display the Standard Mandatory DoD Notice and Consent Banner before granting local access to the system via a graphical user logon.
    - dconf_gnome_banner_enabled

    # UBTU-20-010003 The Ubuntu operating system must display the Standard Mandatory DoD Notice and Consent Banner before granting local access to the system via a graphical user logon.
    - login_banner_text=dod_banners
    - dconf_gnome_login_banner_text

    # UBTU-20-010004 The Ubuntu operating system must retain a user's session lock until that user reestablishes access using established identification and authentication procedures.
    - dconf_gnome_screensaver_lock_enabled

    # UBTU-20-010005 The Ubuntu operating system must allow users to directly initiate a session lock for all connection types.
    - vlock_installed

    # UBTU-20-010006 The Ubuntu operating system must map the authenticated identity to the user or group account for PKI-based authentication.
    - verify_use_mappers

    # UBTU-20-010007 The Ubuntu operating system must enforce 24 hours/1 day as the minimum password lifetime. Passwords for new users must have a 24 hours/1 day minimum password lifetime restriction.
    - var_accounts_minimum_age_login_defs=1
    - accounts_minimum_age_login_defs

    # UBTU-20-010008 The Ubuntu operating system must enforce a 60-day maximum password lifetime restriction. Passwords for new users must have a 60-day maximum password lifetime restriction.
    - var_accounts_maximum_age_login_defs=60
    - accounts_maximum_age_login_defs

    # UBTU-20-010009 Ubuntu operating systems when booted must require authentication upon booting into single-user and maintenance modes.
    - grub2_uefi_password
    - grub2_password

    # UBTU-20-010010 The Ubuntu operating system must uniquely identify interactive users.
    - no_duplicate_uids

    # UBTU-20-010012 The Ubuntu operating system must ensure only users who need access to security functions are part of sudo group.
    - ensure_sudo_group_restricted

    # UBTU-20-010013 The Ubuntu operating system must automatically terminate a user session after inactivity timeouts have expired.
    - var_accounts_tmout=10_min
    - accounts_tmout

    # UBTU-20-010014 The Ubuntu operating system must require users to reauthenticate for privilege escalation or when changing roles.
    - sudo_require_authentication

    # UBTU-20-010016 The Ubuntu operating system default filesystem permissions must be defined in such a way that all authenticated users can read and modify only their own files.
    - var_accounts_user_umask=077
    - accounts_umask_etc_login_defs

    # UBTU-20-010033 The Ubuntu operating system must implement smart card logins for multifactor authentication for local and network access to privileged and non-privileged accounts.
    - sshd_enable_pubkey_auth
    - smartcard_pam_enabled

    # UBTU-20-010035 The Ubuntu operating system must use strong authenticators in establishing nonlocal maintenance and diagnostic sessions.
    - sshd_enable_pam

    # UBTU-20-010036 The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic after a period of inactivity.
    - var_sshd_set_keepalive=1
    - sshd_set_keepalive

    # UBTU-20-010037 The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic at the end of the session or after 10 minutes of inactivity.
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    # UBTU-20-010038 The Ubuntu operating system must display the Standard Mandatory DoD Notice and Consent Banner before granting any local or remote connection to the system.
    - banner_etc_issue_net
    - sshd_enable_warning_banner_net

    # UBTU-20-010042 The Ubuntu operating system must use SSH to protect the confidentiality and integrity of transmitted information.
    - package_openssh-server_installed
    - service_sshd_enabled

    # UBTU-20-010043 The Ubuntu operating system must configure the SSH daemon to use Message Authentication Codes (MACs) employing FIPS 140-2 approved cryptographic hashes to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
    - sshd_use_approved_macs_ordered_stig

    # UBTU-20-010044 The Ubuntu operating system must configure the SSH daemon to use FIPS 140-2 approved ciphers to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
    - sshd_use_approved_ciphers_ordered_stig

    # UBTU-20-010045 The Ubuntu operating system SSH server must be configured to use only FIPS-validated key exchange algorithms.
    - sshd_use_approved_kex_ordered_stig

    # UBTU-20-010047 The Ubuntu operating system must not allow unattended or automatic login via SSH.
    - sshd_disable_empty_passwords
    - sshd_do_not_permit_user_env

    # UBTU-20-010048 The Ubuntu operating system must be configured so that remote X connections are disabled, unless to fulfill documented and validated mission requirements.
    - sshd_disable_x11_forwarding

    # UBTU-20-010049 The Ubuntu operating system SSH daemon must prevent remote hosts from connecting to the proxy display.
    - sshd_x11_use_localhost

    # UBTU-20-010050 The Ubuntu operating system must enforce password complexity by requiring that at least one upper-case character be used.
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    # UBTU-20-010051 The Ubuntu operating system must enforce password complexity by requiring that at least one lower-case character be used.
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    # UBTU-20-010052 The Ubuntu operating system must enforce password complexity by requiring that at least one numeric character be used.
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    # UBTU-20-010053 The Ubuntu operating system must require the change of at least 8 characters when passwords are changed.
    - var_password_pam_difok=8
    - accounts_password_pam_difok

    # UBTU-20-010054 The Ubuntu operating system must enforce a minimum 15-character password length.
    - var_password_pam_minlen=15
    - accounts_password_pam_minlen

    # UBTU-20-010055 The Ubuntu operating system must enforce password complexity by requiring that at least one special character be used.
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    # UBTU-20-010056 The Ubuntu operating system must prevent the use of dictionary words for passwords.
    - var_password_pam_dictcheck=1
    - accounts_password_pam_dictcheck

    # UBTU-20-010057 The Ubuntu operating system must be configured so that when passwords are changed or new passwords are established, pwquality must be used.
    - var_password_pam_retry=3
    - package_pam_pwquality_installed
    - accounts_password_pam_enforcing
    - accounts_password_pam_retry

    # UBTU-20-010060 The Ubuntu operating system, for PKI-based authentication, must validate certificates by constructing a certification path (which includes status information) to an accepted trust anchor.
    - smartcard_configure_ca

    # UBTU-20-010063 The Ubuntu operating system must implement multifactor authentication for remote access to privileged accounts in such a way that one of the factors is provided by a device separate from the system gaining access.
    - install_smartcard_packages

    # UBTU-20-010064 The Ubuntu operating system must accept Personal Identity Verification (PIV) credentials.
    - package_opensc_installed

    # UBTU-20-010065 The Ubuntu operating system must electronically verify Personal Identity Verification (PIV) credentials.
    - smartcard_configure_cert_checking

    # UBTU-20-010066 The Ubuntu operating system for PKI-based authentication, must implement a local cache of revocation data in case of the inability to access revocation information via the network.
    - smartcard_configure_crl

    # UBTU-20-010070 The Ubuntu operating system must prohibit password reuse for a minimum of five generations.
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    # UBTU-20-010072 The Ubuntu operating system must automatically lock an account until the locked account is released by an administrator when three unsuccessful logon attempts have been made.
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_audit
    - accounts_passwords_pam_faillock_silent
    - accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_interval
    - accounts_passwords_pam_faillock_unlock_time

    # UBTU-20-010074 The Ubuntu operating system must be configured so that the script which runs each 30 days or less to check file integrity is the default one.
    - aide_periodic_cron_checking

    # UBTU-20-010075 The Ubuntu operating system must enforce a delay of at least 4 seconds between logon prompts following a failed logon attempt.
    - var_password_pam_delay=4000000
    - accounts_passwords_pam_faildelay_delay

    # UBTU-20-010100 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/passwd.
    - audit_rules_usergroup_modification_passwd

    # UBTU-20-010101 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/group.
    - audit_rules_usergroup_modification_group

    # UBTU-20-010102 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/shadow.
    - audit_rules_usergroup_modification_shadow

    # UBTU-20-010103 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/gshadow.
    - audit_rules_usergroup_modification_gshadow

    # UBTU-20-010104 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/opasswd.
    - audit_rules_usergroup_modification_opasswd

    # UBTU-20-010117 The Ubuntu operating system must alert the ISSO and SA (at a minimum) in the event of an audit processing failure.
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct

    # UBTU-20-010118 The Ubuntu operating system must shut down by default upon audit failure (unless availability is an overriding concern).
    - var_auditd_disk_full_action=halt
    - auditd_data_disk_full_action

    # UBTU-20-010122 The Ubuntu operating system must be configured so that audit log files are not read or write-accessible by unauthorized users.
    - file_permissions_var_log_audit

    # UBTU-20-010123 The Ubuntu operating system must be configured to permit only authorized users ownership of the audit log files.
    - file_ownership_var_log_audit_stig

    # UBTU-20-010124 The Ubuntu operating system must permit only authorized groups ownership of the audit log files.
    - file_group_ownership_var_log_audit

    # UBTU-20-010128 The Ubuntu operating system must be configured so that the audit log directory is not write-accessible by unauthorized users.
    - directory_permissions_var_log_audit

    # UBTU-20-010133 The Ubuntu operating system must be configured so that audit configuration files are not write-accessible by unauthorized users.
    - file_permissions_etc_audit_rulesd
    - file_permissions_etc_audit_auditd

    # UBTU-20-010134 The Ubuntu operating system must permit only authorized accounts to own the audit configuration files.
    - file_ownership_audit_configuration

    # UBTU-20-010135 The Ubuntu operating system must permit only authorized groups to own the audit configuration files.
    - file_groupownership_audit_configuration

    # UBTU-20-010136 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the su command.
    - audit_rules_privileged_commands_su

    # UBTU-20-010137 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chfn command.
    - audit_rules_privileged_commands_chfn

    # UBTU-20-010138 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the mount command.
    - audit_rules_privileged_commands_mount

    # UBTU-20-010139 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the umount command.
    - audit_rules_privileged_commands_umount

    # UBTU-20-010140 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the ssh-agent command.
    - audit_rules_privileged_commands_ssh_agent

    # UBTU-20-010141 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the ssh-keysign command.
    - audit_rules_privileged_commands_ssh_keysign

    # UBTU-20-010142 The Ubuntu operating system must generate audit records for any use of the setxattr system call.
    - audit_rules_dac_modification_setxattr

    # UBTU-20-010143 The Ubuntu operating system must generate audit records for any use of the lsetxattr system call.
    - audit_rules_dac_modification_lsetxattr

    # UBTU-20-010144 The Ubuntu operating system must generate audit records for any use of the fsetxattr system call.
    - audit_rules_dac_modification_fsetxattr

    # UBTU-20-010145 The Ubuntu operating system must generate audit records for any use of the removexattr system call.
    - audit_rules_dac_modification_removexattr

    # UBTU-20-010146 The Ubuntu operating system must generate audit records for any use of the lremovexattr system call.
    - audit_rules_dac_modification_lremovexattr

    # UBTU-20-010147 The Ubuntu operating system must generate audit records for any use of the fremovexattr system call.
    - audit_rules_dac_modification_fremovexattr

    # UBTU-20-010148 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chown system call.
    - audit_rules_dac_modification_chown

    # UBTU-20-010149 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the fchown system call.
    - audit_rules_dac_modification_fchown

    # UBTU-20-010150 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the fchownat system call.
    - audit_rules_dac_modification_fchownat

    # UBTU-20-010151 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the lchown system call.
    - audit_rules_dac_modification_lchown

    # UBTU-20-010152 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chmod system call.
    - audit_rules_dac_modification_chmod

    # UBTU-20-010153 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the fchmod system call.
    - audit_rules_dac_modification_fchmod

    # UBTU-20-010154 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the fchmodat system call.
    - audit_rules_dac_modification_fchmodat

    # UBTU-20-010155 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the open system call.
    - audit_rules_unsuccessful_file_modification_open

    # UBTU-20-010156 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the truncate system call.
    - audit_rules_unsuccessful_file_modification_truncate

    # UBTU-20-010157 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the ftruncate system call.
    - audit_rules_unsuccessful_file_modification_ftruncate

    # UBTU-20-010158 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the creat system call.
    - audit_rules_unsuccessful_file_modification_creat

    # UBTU-20-010159 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the openat system call.
    - audit_rules_unsuccessful_file_modification_openat

    # UBTU-20-010160 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the open_by_handle_at system call.
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    # UBTU-20-010161 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the sudo command.
    - audit_rules_privileged_commands_sudo

    # UBTU-20-010162 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the sudoedit command.
    - audit_rules_privileged_commands_sudoedit

    # UBTU-20-010163 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chsh command.
    - audit_rules_privileged_commands_chsh

    # UBTU-20-010164 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the newgrp command.
    - audit_rules_privileged_commands_newgrp

    # UBTU-20-010165 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chcon command.
    - audit_rules_execution_chcon

    # UBTU-20-010166 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the apparmor_parser command.
    - audit_rules_privileged_commands_apparmor_parser

    # UBTU-20-010167 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the setfacl command.
    - audit_rules_execution_setfacl

    # UBTU-20-010168 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chacl command.
    - audit_rules_execution_chacl

    # UBTU-20-010169 The Ubuntu operating system must generate audit records for the use and modification of the tallylog file.
    - audit_rules_login_events_tallylog

    # UBTU-20-010170 The Ubuntu operating system must generate audit records for the use and modification of faillog file.
    - audit_rules_login_events_faillog

    # UBTU-20-010171 The Ubuntu operating system must generate audit records for the use and modification of the lastlog file.
    - audit_rules_login_events_lastlog

    # UBTU-20-010172 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the passwd command.
    - audit_rules_privileged_commands_passwd

    # UBTU-20-010173 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the unix_update command.
    - audit_rules_privileged_commands_unix_update

    # UBTU-20-010174 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the gpasswd command.
    - audit_rules_privileged_commands_gpasswd

    # UBTU-20-010175 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chage command.
    - audit_rules_privileged_commands_chage

    # UBTU-20-010176 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the usermod command.
    - audit_rules_privileged_commands_usermod

    # UBTU-20-010177 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the crontab command.
    - audit_rules_privileged_commands_crontab

    # UBTU-20-010178 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the pam_timestamp_check command.
    - audit_rules_privileged_commands_pam_timestamp_check

    # UBTU-20-010179 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the init_module and finit_module syscall.
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_finit

    # UBTU-20-010181 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the delete_module syscall
    - audit_rules_kernel_module_loading_delete

    # UBTU-20-010182 The Ubuntu operating system must produce audit records and reports containing information to establish when, where, what type, the source, and the outcome for all DoD-defined auditable events and actions in near real time.
    - package_audit_installed
    - service_auditd_enabled

    # UBTU-20-010198 The Ubuntu operating system must initiate session audits at system start-up.
    - grub2_audit_argument

    # UBTU-20-010199 The Ubuntu operating system must configure audit tools with a mode of 0755 or less permissive.
    - file_permissions_audit_binaries

    # UBTU-20-010200 The Ubuntu operating system must configure audit tools to be owned by root.
    - file_ownership_audit_binaries

    # UBTU-20-010201 The Ubuntu operating system must configure the audit tools to be group-owned by root.
    - file_groupownership_audit_binaries

    # UBTU-20-010205 The Ubuntu operating system must use cryptographic mechanisms to protect the integrity of audit tools.
    - aide_check_audit_tools

    # UBTU-20-010211 The Ubuntu operating system must prevent all software from executing at higher privilege levels than users executing the software and the audit system must be configured to audit the execution of privileged functions.
    - audit_rules_suid_privilege_function

    # UBTU-20-010215 The Ubuntu operating system must allocate audit record storage capacity to store at least one weeks' worth of audit records, when audit records are not immediately sent to a central audit record storage facility.
    - auditd_audispd_configure_sufficiently_large_partition

    # UBTU-20-010216 The Ubuntu operating system audit event multiplexor must be configured to off-load audit logs onto a different system or storage media from the system being audited.
    - package_audit-audispd-plugins_installed
    - auditd_audispd_configure_remote_server

    # UBTU-20-010217 The Ubuntu operating system must immediately notify the SA and ISSO (at a minimum) when allocated audit record storage volume reaches 75% of the repository maximum audit record storage capacity.
    - var_auditd_space_left_percentage=25pc
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action
    - auditd_data_retention_space_left_percentage

    # UBTU-20-010230 The Ubuntu operating system must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC) or Greenwich Mean Time (GMT).
    - ensure_rtc_utc_configuration

    # UBTU-20-010244 The Ubuntu operating system must generate audit records for privileged activities, nonlocal maintenance, diagnostic sessions and other system-level access.
    - audit_sudo_log_events

    # UBTU-20-010267 The Ubuntu operating system must generate audit records for any successful/unsuccessful use of unlink system call.
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlinkat

    # UBTU-20-010276 The Ubuntu operating system must generate audit records when loading dynamic kernel modules.

    # UBTU-20-010277 The Ubuntu operating system must generate audit records for the /var/log/wtmp file.
    - audit_rules_session_events_wtmp

    # UBTU-20-010278 The Ubuntu operating system must generate audit records for the /var/run/wtmp file.
    - audit_rules_session_events_utmp

    # UBTU-20-010279 The Ubuntu operating system must generate audit records for the /var/log/btmp file.
    - audit_rules_session_events_btmp

    # UBTU-20-010296 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use modprobe command
    - audit_rules_privileged_commands_modprobe

    # UBTU-20-010297 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the kmod command.
    - audit_rules_privileged_commands_kmod

    # UBTU-20-010298 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the fdisk command.
    - audit_rules_privileged_commands_fdisk

    # UBTU-20-010300 The Ubuntu operating system must have a crontab script running weekly to offload audit events of standalone systems.
    - auditd_offload_logs

    # UBTU-20-010400 The Ubuntu operating system must limit the number of concurrent sessions to ten for all accounts and/or account types.
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions

    #UBTU-20-010401 The Ubuntu operating system must restrict access to the kernel message buffer.
    - sysctl_kernel_dmesg_restrict

    # UBTU-20-010403 The Ubuntu operating system must monitor remote access methods.
    - rsyslog_remote_access_monitoring

    # UBTU-20-010404 The Ubuntu operating system must encrypt all stored passwords with a FIPS 140-2 approved cryptographic hashing algorithm.
    - set_password_hashing_algorithm_logindefs

    # UBTU-20-010405 The Ubuntu operating system must not have the telnet package installed.
    - package_telnetd_removed

    # UBTU-20-010406 The Ubuntu operating system must not have the rsh-server package installed.
    - package_rsh-server_removed

    # UBTU-20-010407 The Ubuntu operating system must be configured to prohibit or restrict the use of functions, ports, protocols, and/or services, as defined in the PPSM CAL and vulnerability assessments.
    - ufw_only_required_services

    # UBTU-20-010408 The Ubuntu operating system must prevent direct login into the root account.
    - prevent_direct_root_logins

    # UBTU-20-010409 The Ubuntu operating system must disable account identifiers (individuals, groups, roles, and devices) after 35 days of inactivity.
    - account_disable_post_pw_expiration

    # UBTU-20-010410 The Ubuntu operating system must automatically remove or disable emergency accounts after 72 hours.

    # UBTU-20-010411 The Ubuntu operating system must set a sticky bit  on all public directories to prevent unauthorized and unintended information transferred via shared system resources.
    - dir_perms_world_writable_sticky_bits

    # UBTU-20-010412 The Ubuntu operating system must be configured to use TCP syncookies.
    - sysctl_net_ipv4_tcp_syncookies

    # UBTU-20-010413 The Ubuntu operating system must disable kernel core dumps  so that it can fail to a secure state if system initialization fails, shutdown fails or aborts fail.
    - service_kdump_disabled

    # UBTU-20-010414 Ubuntu operating systems handling data requiring "data at rest" protections must employ cryptographic mechanisms to prevent unauthorized disclosure and modification of the information at rest.
    - encrypt_partitions

    # UBTU-20-010415 The Ubuntu operating system must deploy Endpoint Security for Linux Threat Prevention (ENSLTP).
    - package_mcafeetp_installed

    # UBTU-20-010416 The Ubuntu operating system must generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.
    - permissions_local_var_log

    # UBTU-20-010417 The Ubuntu operating system must configure the /var/log directory to be group-owned by syslog.
    - file_groupowner_var_log

    # UBTU-20-010418 The Ubuntu operating system must configure the /var/log directory to be owned by root.
    - file_owner_var_log

    # UBTU-20-010419 The Ubuntu operating system must configure the /var/log directory to have mode 0750 or less permissive.
    - file_permissions_var_log

    # UBTU-20-010420 The Ubuntu operating system must configure the /var/log/syslog file to be group-owned by adm.
    - file_groupowner_var_log_syslog

    # UBTU-20-010421 The Ubuntu operating system must configure /var/log/syslog file to be owned by syslog.
    - file_owner_var_log_syslog

    # UBTU-20-010422 The Ubuntu operating system must configure /var/log/syslog file with mode 0640 or less permissive.
    - file_permissions_var_log_syslog

    # UBTU-20-010423 The Ubuntu operating system must have directories that contain system commands set to a mode of 0755 or less permissive.
    - dir_permissions_binary_dirs

    # UBTU-20-010424 The Ubuntu operating system must have directories that contain system commands owned by root.
    - dir_ownership_binary_dirs

    # UBTU-20-010425 The Ubuntu operating system must have directories that contain system commands group-owned by root.
    - dir_groupownership_binary_dirs

    # UBTU-20-010426 The Ubuntu operating system library files must have mode 0755 or less permissive.
    - file_permissions_library_dirs

    # UBTU-20-010427 The Ubuntu operating system library directories must have mode 0755 or less permissive.
    - dir_permissions_library_dirs

    # UBTU-20-010428 The Ubuntu operating system library files must be owned by root.
    - file_ownership_library_dirs

    # UBTU-20-010429 The Ubuntu operating system library directories must be owned by root.
    - dir_ownership_library_dirs

    # UBTU-20-010430 The Ubuntu operating system library files must be group-owned by root.
    - root_permissions_syslibrary_files

    # UBTU-20-010431 The Ubuntu operating system library directories must be group-owned by root.
    - dir_group_ownership_library_dirs

    # UBTU-20-010432 The Ubuntu operating system must be configured to preserve log records from failure events.
    - service_rsyslog_enabled

    # UBTU-20-010433 The Ubuntu operating system must have an application firewall installed in order to control remote access methods.
    - package_ufw_installed

    # UBTU-20-010434 The Ubuntu operating system must enable and run the uncomplicated firewall(ufw).
    - service_ufw_enabled

    # UBTU-20-010435 The Ubuntu operating system must, for networked systems, compare internal information system clocks at least every 24 hours with a server which is synchronized to one of the redundant United States Naval Observatory (USNO) time servers, or a time server designated for the appropriate DoD network (NIPRNet/SIPRNet), and/or the Global Positioning System (GPS).
    - var_time_service_set_maxpoll=36_hours
    - package_chrony_installed
    - chronyd_or_ntpd_set_maxpoll

    # UBTU-20-010436 The Ubuntu operating system must synchronize internal information system clocks to the authoritative time source when the time difference is greater than one second.
    - chronyd_sync_clock

    # UBTU-20-010437 The Ubuntu operating system must notify designated personnel if baseline configurations are changed in an unauthorized manner. The file integrity tool must notify the System Administrator when changes to the baseline configuration or anomalies in the oper
    - aide_disable_silentreports

    # UBTU-20-010438 The Ubuntu operating system's Advance Package Tool (APT) must be configured to prevent the installation of patches, service packs, device drivers, or Ubuntu operating system components without verification they have been digitally signed using a certificate that is recognized and approved by the organization.
    - apt_conf_disallow_unauthenticated

    # UBTU-20-010439 The Ubuntu operating system must be configured to use AppArmor.
    - package_apparmor_installed
    - apparmor_configured

    # UBTU-20-010440 The Ubuntu operating system must allow the use of a temporary password for system logons with an immediate change to a permanent password.
    - policy_temp_passwords_immediate_change

    # UBTU-20-010441 The Ubuntu operating system must be configured such that Pluggable Authentication Module (PAM) prohibits the use of cached authentications after one day.
    - sssd_offline_cred_expiration

    # UBTU-20-010442 The Ubuntu operating system must implement NIST FIPS-validated cryptography  to protect classified information and for the following: to provision digital signatures, to generate cryptographic hashes, and to protect unclassified information requiring confidentiality and cryptographic protection in accordance with applicable federal laws, Executive Orders, directives, policies, regulations, and standards.
    - is_fips_mode_enabled

    # UBTU-20-010443 The Ubuntu operating system must only allow the use of DoD PKI-established certificate authorities for verification of the establishment of protected sessions.
    - only_allow_dod_certs

    # UBTU-20-010444 Ubuntu operating system must implement cryptographic mechanisms to prevent unauthorized modification of all information at rest.

    # UBTU-20-010445 Ubuntu operating system must implement cryptographic mechanisms to prevent unauthorized disclosure of all information at rest.

    # UBTU-20-010446 The Ubuntu operating system must configure the uncomplicated firewall to rate-limit impacted network interfaces.
    - ufw_rate_limit

    # UBTU-20-010447 The Ubuntu operating system must implement non-executable data to protect its memory from unauthorized code execution.
    - bios_enable_execution_restrictions

    # UBTU-20-010448 The Ubuntu operating system must implement address space layout randomization to protect its memory from unauthorized code execution.
    - sysctl_kernel_randomize_va_space

    # UBTU-20-010449 The Ubuntu operating system must be configured so that Advance Package Tool (APT) removes all software components after updated versions have been installed.
    - clean_components_post_updating

    # UBTU-20-010450 The Ubuntu operating system must use a file integrity tool to verify correct operation of all security functions.
    - package_aide_installed
    - aide_build_database

    # UBTU-20-010451 The Ubuntu operating system must notify designated personnel if baseline configurations are changed in an unauthorized manner. The file integrity tool must notify the System Administrator when changes to the baseline configuration or anomalies in the operation of any security functions are discovered.
    # Same as UBTU-20-010437

    # UBTU-20-010453 The Ubuntu operating system must display the date and time of the last successful account logon upon logon.
    - display_login_attempts

    # UBTU-20-010454 The Ubuntu operating system must have an application firewall enabled.

    # UBTU-20-010455 The Ubuntu operating system must disable all wireless network adapters.
    - wireless_disable_interfaces

    # UBTU-20-010456 The Ubuntu operating system must have system commands set to a mode of 0755 or less permissive.
    - file_permissions_binary_dirs

    # UBTU-20-010457 The Ubuntu operating system must have system commands owned by root.
    - file_ownership_binary_dirs

    # UBTU-20-010458 The Ubuntu operating system must have system commands group-owned by root.
    - file_groupownership_system_commands_dirs

    # UBTU-20-010459 The Ubuntu operating system must disable the x86 Ctrl-Alt-Delete key sequence if a graphical user interface is installed.
    - dconf_gnome_disable_ctrlaltdel_reboot

    # UBTU-20-010460 The Ubuntu operating system must disable the x86 Ctrl-Alt-Delete key sequence.
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction

    # UBTU-20-010461 The Ubuntu operating system must disable automatic mounting of Universal Serial Bus (USB) mass storage driver.
    - kernel_module_usb-storage_disabled

    # UBTU-20-010462 The Ubuntu operating system must not have accounts configured with blank or null passwords.
    - no_empty_passwords_etc_shadow

    # UBTU-20-010463 The Ubuntu operating system must not allow accounts configured with blank or null passwords.
    - no_empty_passwords
