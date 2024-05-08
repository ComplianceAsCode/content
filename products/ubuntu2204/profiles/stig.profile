documentation_complete: true

title: 'DRAFT Canonical Ubuntu 22.04 LTS Security Technical Implementation Guide (STIG) DRAFT'

description: |-
    This Security Technical Implementation Guide is published as a tool to
    improve the security of Department of Defense (DoD) information systems.
    The requirements are derived from the National Institute of Standards and
    Technology (NIST) 800-53 and related documents.

selections:

    ### TODO
    # UBTU-22-271010 The Ubuntu operating system must enable the graphical user logon banner to display the Standard Mandatory DoD Notice and Consent Banner before granting local access to the system via a graphical user logon.
    - enable_dconf_user_profile
    - dconf_gnome_banner_enabled

    ### TODO
    # UBTU-22-271015 The Ubuntu operating system must display the Standard Mandatory DoD Notice and Consent Banner before granting local access to the system via a graphical user logon.
    - login_banner_text=dod_banners
    - dconf_gnome_login_banner_text

    # UBTU-22-271020 The Ubuntu operating system must retain a user's session lock until that user reestablishes access using established identification and authentication procedures.
    - dconf_gnome_screensaver_lock_enabled

    # UBTU-22-412025 The Ubuntu operating system must allow users to directly initiate a session lock for all connection types.
    - vlock_installed

    # UBTU-22-612040 The Ubuntu operating system must map the authenticated identity to the user or group account for PKI-based authentication.
    - verify_use_mappers

    # UBTU-22-411025 The Ubuntu operating system must enforce 24 hours/1 day as the minimum password lifetime. Passwords for new users must have a 24 hours/1 day minimum password lifetime restriction.
    - var_accounts_minimum_age_login_defs=1
    - accounts_minimum_age_login_defs

    # UBTU-22-411030 The Ubuntu operating system must enforce a 60-day maximum password lifetime restriction. Passwords for new users must have a 60-day maximum password lifetime restriction.
    - var_accounts_maximum_age_login_defs=60
    - accounts_maximum_age_login_defs

    # UBTU-22-212010 Ubuntu operating systems when booted must require authentication upon booting into single-user and maintenance modes.
    - grub2_uefi_password
    - grub2_password

    # UBTU-22-411015 The Ubuntu operating system must uniquely identify interactive users.
    - no_duplicate_uids

    # UBTU-22-432015 The Ubuntu operating system must ensure only users who need access to security functions are part of sudo group.
    - ensure_sudo_group_restricted

    # UBTU-22-412030 The Ubuntu operating system must automatically terminate a user session after inactivity timeouts have expired.
    - var_accounts_tmout=15_min
    - accounts_tmout

    # UBTU-22-432010 The Ubuntu operating system must require users to reauthenticate for privilege escalation or when changing roles.
    - sudo_require_authentication

    # UBTU-22-412035 The Ubuntu operating system default filesystem permissions must be defined in such a way that all authenticated users can read and modify only their own files.
    - var_accounts_user_umask=077
    - accounts_umask_etc_login_defs

    # UBTU-22-612010 The Ubuntu operating system must implement multifactor authentication for remote access to privileged accounts in such a way that one of the factors is provided by a device separate from the system gaining access.
    - install_smartcard_packages

    # UBTU-22-612020 The Ubuntu operating system must implement smart card logins for multifactor authentication for local and network access to privileged and non-privileged accounts.
    - sshd_enable_pubkey_auth
    - smartcard_pam_enabled

    # UBTU-22-255065 The Ubuntu operating system must use strong authenticators in establishing nonlocal maintenance and diagnostic sessions.
    - sshd_enable_pam

    # UBTU-22-255030 The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic after a period of inactivity.
    - var_sshd_set_keepalive=1
    - sshd_set_keepalive

    # UBTU-22-255035 The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic at the end of the session or after 10 minutes of inactivity.
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    # UBTU-22-255010 The Ubuntu operating system must use SSH to protect the confidentiality and integrity of transmitted information.
    - package_openssh-server_installed

    # UBTU-22-255015 The Ubuntu operating system must use SSH to protect the confidentiality and integrity of transmitted information.
    - service_sshd_enabled

    # UBTU-22-255020 The Ubuntu operating system must display the Standard Mandatory DoD Notice and Consent Banner before granting any local or remote connection to the system.
    - banner_etc_issue_net
    - sshd_enable_warning_banner_net

    ### TODO
    # UBTU-22-255055 The Ubuntu operating system must configure the SSH daemon to use Message Authentication Codes (MACs) employing FIPS 140-3 approved cryptographic hashes to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
    - sshd_use_approved_macs_ordered_stig

    ### TODO
    # UBTU-22-255050 The Ubuntu operating system must configure the SSH daemon to use FIPS 140-3 approved ciphers to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
    - sshd_use_approved_ciphers_ordered_stig

    # UBTU-22-255060 The Ubuntu operating system SSH server must be configured to use only FIPS-validated key exchange algorithms.
    - sshd_use_approved_kex_ordered_stig

    # UBTU-22-255025 The Ubuntu operating system must not allow unattended or automatic login via SSH.
    - sshd_disable_empty_passwords
    - sshd_do_not_permit_user_env

    # UBTU-22-255040 The Ubuntu operating system must be configured so that remote X connections are disabled, unless to fulfill documented and validated mission requirements.
    - sshd_disable_x11_forwarding

    # UBTU-22-255045 The Ubuntu operating system SSH daemon must prevent remote hosts from connecting to the proxy display.
    - sshd_x11_use_localhost

    # UBTU-22-611010 The Ubuntu operating system must enforce password complexity by requiring that at least one upper-case character be used.
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    # UBTU-22-611015 The Ubuntu operating system must enforce password complexity by requiring that at least one lower-case character be used.
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    # UBTU-22-611020 The Ubuntu operating system must enforce password complexity by requiring that at least one numeric character be used.
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    # UBTU-22-611040 The Ubuntu operating system must require the change of at least 8 characters when passwords are changed.
    - var_password_pam_difok=8
    - accounts_password_pam_difok

    # UBTU-22-611035 The Ubuntu operating system must enforce a minimum 15-character password length.
    - var_password_pam_minlen=15
    - accounts_password_pam_minlen

    # UBTU-22-611025 The Ubuntu operating system must enforce password complexity by requiring that at least one special character be used.
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    # UBTU-22-611030 The Ubuntu operating system must prevent the use of dictionary words for passwords.
    - var_password_pam_dictcheck=1
    - accounts_password_pam_dictcheck

    # UBTU-22-215010 The Ubuntu operating system must be configured so that when passwords are changed or new passwords are established, pwquality must be used.
    - package_pam_pwquality_installed

    # UBTU-22-611045 The Ubuntu operating system must be configured so that when passwords are changed or new passwords are established, pwquality must be used.
    - var_password_pam_retry=3
    - accounts_password_pam_enforcing
    - accounts_password_pam_retry

    # UBTU-22-612030 The Ubuntu operating system, for PKI-based authentication, must validate certificates by constructing a certification path (which includes status information) to an accepted trust anchor.
    - smartcard_configure_ca


    # UBTU-22-612015 The Ubuntu operating system must accept Personal Identity Verification (PIV) credentials.
    - package_opensc_installed

    ### TODO
    # UBTU-22-612025 The Ubuntu operating system must electronically verify Personal Identity Verification (PIV) credentials.
    - smartcard_configure_cert_checking

    ### TODO
    # UBTU-22-612035 The Ubuntu operating system for PKI-based authentication, must implement a local cache of revocation data in case of the inability to access revocation information via the network.
    - smartcard_configure_crl

    # UBTU-22-611050 The Ubuntu operating system must prohibit password reuse for a minimum of five generations.
    - var_password_pam_unix_remember=5
    - accounts_password_pam_unix_remember

    # UBTU-22-411045 The Ubuntu operating system must automatically lock an account until the locked account is released by an administrator when three unsuccessful logon attempts have been made.
    - var_accounts_passwords_pam_faillock_deny=3
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_audit
    - accounts_passwords_pam_faillock_silent
    - accounts_passwords_pam_faillock_deny
    - accounts_passwords_pam_faillock_interval
    - accounts_passwords_pam_faillock_unlock_time

    ### TODO
    # UBTU-22-651025 The Ubuntu operating system must be configured so that the script which runs each 30 days or less to check file integrity is the default one.
    - aide_periodic_cron_checking

    # UBTU-22-412010 The Ubuntu operating system must enforce a delay of at least 4 seconds between logon prompts following a failed logon attempt.
    - var_password_pam_delay=4000000
    - accounts_passwords_pam_faildelay_delay

    # UBTU-22-654145 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/passwd.
    - audit_rules_usergroup_modification_passwd

    # UBTU-22-654130 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/group.
    - audit_rules_usergroup_modification_group

    # UBTU-22-654150 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/shadow.
    - audit_rules_usergroup_modification_shadow

    # UBTU-22-654135 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/gshadow.
    - audit_rules_usergroup_modification_gshadow

    # UBTU-22-654140 The Ubuntu operating system must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/opasswd.
    - audit_rules_usergroup_modification_opasswd

    ### TODO
    # UBTU-22-653025 The Ubuntu operating system must alert the ISSO and SA (at a minimum) in the event of an audit processing failure.
    - var_auditd_action_mail_acct=root
    - auditd_data_retention_action_mail_acct

    ### TODO
    # UBTU-22-653030 The Ubuntu operating system must shut down by default upon audit failure (unless availability is an overriding concern).
    - var_auditd_disk_full_action=halt
    - auditd_data_disk_full_action

    # UBTU-22-653045 The Ubuntu operating system must be configured so that audit log files are not read or write-accessible by unauthorized users.
    - file_permissions_var_log_audit_stig

    # UBTU-22-653050 The Ubuntu operating system must be configured to permit only authorized users ownership of the audit log files.
    - file_ownership_var_log_audit_stig

    # UBTU-22-653055 The Ubuntu operating system must permit only authorized groups ownership of the audit log files.
    - file_group_ownership_var_log_audit_stig

    # UBTU-22-653060 The Ubuntu operating system must be configured so that the audit log directory is not write-accessible by unauthorized users.
    - directory_permissions_var_log_audit

    # UBTU-22-653065 The Ubuntu operating system must be configured so that audit configuration files are not write-accessible by unauthorized users.
    - file_permissions_etc_audit_rules
    - file_permissions_etc_audit_rulesd
    - file_permissions_etc_audit_auditd

    # UBTU-22-653070 The Ubuntu operating system must permit only authorized accounts to own the audit configuration files.
    - file_ownership_audit_configuration

    # UBTU-22-653075 The Ubuntu operating system must permit only authorized groups to own the audit configuration files.
    - file_groupownership_audit_configuration

    # UBTU-22-654100 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the su command.
    - audit_rules_privileged_commands_su

    # UBTU-22-654030 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chfn command.
    - audit_rules_privileged_commands_chfn

    # UBTU-22-654065 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the mount command.
    - audit_rules_privileged_commands_mount

    # UBTU-22-654115 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the umount command.
    - audit_rules_privileged_commands_umount

    # UBTU-22-654090 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the ssh-agent command.
    - audit_rules_privileged_commands_ssh_agent

    # UBTU-22-654095 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the ssh-keysign command.
    - audit_rules_privileged_commands_ssh_keysign

    # UBTU-22-654180 The Ubuntu operating system must generate audit records for any use of the setxattr, fsetxattr, lsetxattr, removexattr, fremovexattr, and lremovexattr system calls
    - audit_rules_dac_modification_setxattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_fremovexattr

    # UBTU-22-654160 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chown, fchown, fchownat, and lchown system calls.
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_lchown

    # UBTU-22-654155 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chmod, fchmod, and fchmodat system calls.
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat

    # UBTU-22-654165 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the creat, open, openat, open_by_handle_at, truncate, and ftruncate system calls.
    - audit_rules_unsuccessful_file_modification_open
    - audit_rules_unsuccessful_file_modification_truncate
    - audit_rules_unsuccessful_file_modification_ftruncate
    - audit_rules_unsuccessful_file_modification_creat
    - audit_rules_unsuccessful_file_modification_openat
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    # UBTU-22-654105 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the sudo command.
    - audit_rules_privileged_commands_sudo

    # UBTU-22-654110 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the sudoedit command.
    - audit_rules_privileged_commands_sudoedit

    # UBTU-22-654035 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chsh command.
    - audit_rules_privileged_commands_chsh

    # UBTU-22-654070 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the newgrp command.
    - audit_rules_privileged_commands_newgrp

    # UBTU-22-654025 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chcon command.
    - audit_rules_execution_chcon

    # UBTU-22-654010 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the apparmor_parser command.
    - audit_rules_privileged_commands_apparmor_parser

    # UBTU-22-654085 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the setfacl command.
    - audit_rules_execution_setfacl

    # UBTU-22-654015 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chacl command.
    - audit_rules_execution_chacl

    # UBTU-22-654210 The Ubuntu operating system must generate audit records for the use and modification of faillog file.
    - audit_rules_login_events_faillog

    # UBTU-22-654215 The Ubuntu operating system must generate audit records for the use and modification of the lastlog file.
    - audit_rules_login_events_lastlog

    # UBTU-22-654080 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the passwd command.
    - audit_rules_privileged_commands_passwd

    # UBTU-22-654120 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the unix_update command.
    - audit_rules_privileged_commands_unix_update

    # UBTU-22-654050 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the gpasswd command.
    - audit_rules_privileged_commands_gpasswd

    # UBTU-22-654020 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the chage command.
    - audit_rules_privileged_commands_chage

    # UBTU-22-654125 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the usermod command.
    - audit_rules_privileged_commands_usermod

    # UBTU-22-654040 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the crontab command.
    - audit_rules_privileged_commands_crontab

    # UBTU-22-654075 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the pam_timestamp_check command.
    - audit_rules_privileged_commands_pam_timestamp_check

    # UBTU-22-654175 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the init_module and finit_module syscall.
    - audit_rules_kernel_module_loading_init
    - audit_rules_kernel_module_loading_finit

    # UBTU-22-654170 The Ubuntu operating system must generate audit records for successful/unsuccessful uses of the delete_module syscall
    - audit_rules_kernel_module_loading_delete

    # UBTU-22-653010 The Ubuntu operating system must have the "auditd" package installed
    - package_audit_installed

    # UBTU-22-653015 The Ubuntu operating system must produce audit records and reports containing information to establish when, where, what type, the source, and the outcome for all DoD-defined auditable events and actions in near real time.
    - service_auditd_enabled

    # UBTU-22-212015 The Ubuntu operating system must initiate session audits at system start-up.
    - grub2_audit_argument

    # UBTU-22-232035 The Ubuntu operating system must configure audit tools with a mode of 0755 or less permissive.
    - file_permissions_audit_binaries

    # UBTU-22-232110 The Ubuntu operating system must configure audit tools to be owned by root.
    - file_ownership_audit_binaries

    # UBTU-22-651030 The Ubuntu operating system must use cryptographic mechanisms to protect the integrity of audit tools.
    - aide_check_audit_tools

    # UBTU-22-654230 The Ubuntu operating system must prevent all software from executing at higher privilege levels than users executing the software and the audit system must be configured to audit the execution of privileged functions.
    - audit_rules_suid_privilege_function

    ### TODO
    # UBTU-22-653035 The Ubuntu operating system must allocate audit record storage capacity to store at least one weeks' worth of audit records, when audit records are not immediately sent to a central audit record storage facility.
    - auditd_audispd_configure_sufficiently_large_partition

    ### TODO
    # UBTU-22-653020 The Ubuntu operating system audit event multiplexor must be configured to off-load audit logs onto a different system or storage media from the system being audited.
    #- var_audispd_remote_server=192.168.122.126
    - package_audit-audispd-plugins_installed
    - auditd_audispd_configure_remote_server

    # UBTU-22-653040 The Ubuntu operating system must immediately notify the SA and ISSO (at a minimum) when allocated audit record storage volume reaches 75% of the repository maximum audit record storage capacity.
    - var_auditd_space_left_percentage=25pc
    - var_auditd_space_left_action=email
    - auditd_data_retention_space_left_action
    - auditd_data_retention_space_left_percentage

    # UBTU-22-252020 The Ubuntu operating system must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC) or Greenwich Mean Time (GMT).
    - ensure_rtc_utc_configuration

    # UBTU-22-654235 The Ubuntu operating system must generate audit records for privileged activities, nonlocal maintenance, diagnostic sessions and other system-level access.
    - audit_sudo_log_events

    # UBTU-22-654185 The Ubuntu operating system must generate audit records for any successful/unsuccessful use of unlink, unlinkat, rename, renameat, and rmdir system calls.
    - audit_rules_file_deletion_events_unlink
    - audit_rules_file_deletion_events_rmdir
    - audit_rules_file_deletion_events_renameat
    - audit_rules_file_deletion_events_rename
    - audit_rules_file_deletion_events_unlinkat

    # UBTU-22-654200 The Ubuntu operating system must generate audit records for the /var/log/wtmp file.
    - audit_rules_session_events_wtmp

    # UBTU-22-654205 The Ubuntu operating system must generate audit records for the /var/run/wtmp file.
    - audit_rules_session_events_utmp

    # UBTU-22-654195 The Ubuntu operating system must generate audit records for the /var/log/btmp file.
    - audit_rules_session_events_btmp

    # UBTU-22-654060 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use modprobe command
    - audit_rules_privileged_commands_modprobe

    ### TODO (double check, focal uses kmod_0)
    # UBTU-22-654055 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the kmod command.
    - audit_rules_privileged_commands_kmod

    # UBTU-22-654045 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the fdisk command.
    - audit_rules_privileged_commands_fdisk

    ### TODO
    # UBTU-22-651035 The Ubuntu operating system must have a crontab script running weekly to offload audit events of standalone systems.
    - auditd_offload_logs

    ### TODO
    # UBTU-22-412020 The Ubuntu operating system must limit the number of concurrent sessions to ten for all accounts and/or account types.
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions

    # UBTU-22-213010 The Ubuntu operating system must restrict access to the kernel message buffer.
    - sysctl_kernel_dmesg_restrict

    ### TODO
    # UBTU-22-652015 The Ubuntu operating system must monitor remote access methods.
    - rsyslog_remote_access_monitoring

    # UBTU-22-611070 The Ubuntu operating system must encrypt all stored passwords with a FIPS 140-3 approved cryptographic hashing algorithm.
    - set_password_hashing_algorithm_logindefs

    # UBTU-22-215035 The Ubuntu operating system must not have the telnet package installed.
    - package_telnetd_removed

    # UBTU-22-215030 The Ubuntu operating system must not have the rsh-server package installed.
    - package_rsh-server_removed

    # UBTU-22-251030 The Ubuntu operating system must be configured to prohibit or restrict the use of functions, ports, protocols, and/or services, as defined in the PPSM CAL and vulnerability assessments.
    - ufw_only_required_services

    # UBTU-22-411010 The Ubuntu operating system must prevent direct login into the root account.
    - prevent_direct_root_logins

    # UBTU-22-411035 The Ubuntu operating system must disable account identifiers (individuals, groups, roles, and devices) after 35 days of inactivity.
    - account_disable_post_pw_expiration

    ### TODO
    # UBTU-22-411040 The Ubuntu operating system must provision temporary user accounts with an expiration time of 72 hours or less.
    - account_temp_expire_date

    # UBTU-22-232145 The Ubuntu operating system must set a sticky bit  on all public directories to prevent unauthorized and unintended information transferred via shared system resources.
    - dir_perms_world_writable_sticky_bits

    ### TODO
    # UBTU-22-253010 The Ubuntu operating system must be configured to use TCP syncookies.
    - sysctl_net_ipv4_tcp_syncookies

    # UBTU-22-213015 The Ubuntu operating system must disable kernel core dumps  so that it can fail to a secure state if system initialization fails, shutdown fails or aborts fail.
    - service_kdump_disabled

    # UBTU-22-231010 Ubuntu operating systems handling data requiring "data at rest" protections must employ cryptographic mechanisms to prevent unauthorized disclosure and modification of the information at rest.
    - encrypt_partitions

    ### TODO
    # UBTU-22-211010 The Ubuntu operating system must deploy Endpoint Security for Linux Threat Prevention (ENSLTP).
    #- package_mfetp_installed

    # UBTU-22-232026 The Ubuntu operating system must generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.
    - permissions_local_var_log

    # UBTU-22-232125 The Ubuntu operating system must configure the /var/log directory to be group-owned by syslog.
    - file_groupowner_var_log

    # UBTU-22-232120 The Ubuntu operating system must configure the /var/log directory to be owned by root.
    - file_owner_var_log

    # UBTU-22-232025 The Ubuntu operating system must configure the /var/log directory to have mode 0750 or less permissive.
    - file_permissions_var_log

    # UBTU-22-232135 The Ubuntu operating system must configure the /var/log/syslog file to be group-owned by adm.
    - file_groupowner_var_log_syslog

    # UBTU-22-232130 The Ubuntu operating system must configure /var/log/syslog file to be owned by syslog.
    - file_owner_var_log_syslog

    # UBTU-22-232030 The Ubuntu operating system must configure /var/log/syslog file with mode 0640 or less permissive.
    - file_permissions_var_log_syslog

    # UBTU-22-232010 The Ubuntu operating system must have directories that contain system commands set to a mode of 0755 or less permissive.
    - dir_permissions_binary_dirs

    # UBTU-22-232040 The Ubuntu operating system must have directories that contain system commands owned by root.
    - dir_ownership_binary_dirs

    # UBTU-22-232045 The Ubuntu operating system must have directories that contain system commands group-owned by root.
    - dir_groupownership_binary_dirs

    # UBTU-22-232020 The Ubuntu operating system library files must have mode 0755 or less permissive.
    - file_permissions_library_dirs

    # UBTU-22-232070 The Ubuntu operating system library files must be owned by root.
    - file_ownership_library_dirs

    # UBTU-22-232060 The Ubuntu operating system library directories must be owned by root.
    - dir_ownership_library_dirs

    # UBTU-22-232075 The Ubuntu operating system library files must be group-owned by root.
    - root_permissions_syslibrary_files

    # UBTU-22-232065 The Ubuntu operating system library directories must be group-owned by root.
    - dir_group_ownership_library_dirs

    # UBTU-22-652010 The Ubuntu operating system must be configured to preserve log records from failure events.
    - service_rsyslog_enabled

    # UBTU-22-251010 The Ubuntu operating system must have an application firewall installed in order to control remote access methods.
    - package_ufw_installed

    # UBTU-22-215015 The Ubuntu operating system must have the "chrony" package installed
    - package_chrony_installed

    ### TODO
    # UBTU-22-252010 The Ubuntu operating system must, for networked systems, compare internal information system clocks at least every 24 hours with a server which is synchronized to one of the redundant United States Naval Observatory (USNO) time servers, or a time server designated for the appropriate DoD network (NIPRNet/SIPRNet), and/or the Global Positioning System (GPS).
    - var_time_service_set_maxpoll=18_hours
    - chronyd_or_ntpd_set_maxpoll

    ### TODO
    # UBTU-22-252015 The Ubuntu operating system must synchronize internal information system clocks to the authoritative time source when the time difference is greater than one second.
    - chronyd_sync_clock

    # UBTU-22-651020 The Ubuntu operating system must notify designated personnel if baseline configurations are changed in an unauthorized manner. The file integrity tool must notify the System Administrator when changes to the baseline configuration or anomalies in the oper
    - aide_disable_silentreports

    ### TODO
    # UBTU-22-214010 The Ubuntu operating system's Advance Package Tool (APT) must be configured to prevent the installation of patches, service packs, device drivers, or Ubuntu operating system components without verification they have been digitally signed using a certificate that is recognized and approved by the organization.
    - apt_conf_disallow_unauthenticated

    # UBTU-22-431010 The Ubuntu operating system must be configured to use AppArmor.
    - package_apparmor_installed

    # UBTU-22-431015 The Ubuntu operating system must be configured to use AppArmor.
    - apparmor_configured

    # UBTU-22-411020 The Ubuntu operating system must allow the use of a temporary password for system logons with an immediate change to a permanent password.
    - policy_temp_passwords_immediate_change

    ### TODO
    # UBTU-22-631015 The Ubuntu operating system must be configured such that Pluggable Authentication Module (PAM) prohibits the use of cached authentications after one day.
    - sssd_offline_cred_expiration

    # UBTU-22-671010 The Ubuntu operating system must implement NIST FIPS-validated cryptography  to protect classified information and for the following: to provision digital signatures, to generate cryptographic hashes, and to protect unclassified information requiring confidentiality and cryptographic protection in accordance with applicable federal laws, Executive Orders, directives, policies, regulations, and standards.
    - is_fips_mode_enabled

    ### TODO
    # UBTU-22-631010 The Ubuntu operating system must only allow the use of DoD PKI-established certificate authorities for verification of the establishment of protected sessions.
    - only_allow_dod_certs

    ### TODO
    # UBTU-22-251025 The Ubuntu operating system must configure the uncomplicated firewall to rate-limit impacted network interfaces.
    - ufw_rate_limit

    ### TODO
    # UBTU-22-213025 The Ubuntu operating system must implement non-executable data to protect its memory from unauthorized code execution.
    - bios_enable_execution_restrictions

    # UBTU-22-213020 The Ubuntu operating system must implement address space layout randomization to protect its memory from unauthorized code execution.
    - sysctl_kernel_randomize_va_space

    # UBTU-22-214015 The Ubuntu operating system must be configured so that Advance Package Tool (APT) removes all software components after updated versions have been installed.
    - clean_components_post_updating

    # UBTU-22-651010 The Ubuntu operating system must use a file integrity tool to verify correct operation of all security functions.
    - package_aide_installed

    ### TODO
    # UBTU-22-651015 The Ubuntu operating system must use a file integrity tool to verify correct operation of all security functions.
    - aide_build_database

    ### TODO
    # UBTU-22-412015 The Ubuntu operating system must display the date and time of the last successful account logon upon logon.
    - display_login_attempts

    # UBTU-22-251015 The Ubuntu operating system must have an application firewall enabled.
    - service_ufw_enabled

    # UBTU-22-251020 The Ubuntu operating system must have an application firewall enabled.
    # same as UBTU-22-251015

    ### TODO
    # UBTU-22-291015 The Ubuntu operating system must disable all wireless network adapters.
    - wireless_disable_interfaces

    # UBTU-22-232015 The Ubuntu operating system must have system commands set to a mode of 0755 or less permissive.
    # rule has a few extra directories
    - file_permissions_binary_dirs

    # UBTU-22-232050 The Ubuntu operating system must have system commands owned by root.
    - file_ownership_binary_dirs

    # UBTU-22-232055 The Ubuntu operating system must have system commands group-owned by root.
    - file_groupownership_system_commands_dirs

    ### TODO
    # UBTU-22-271030 The Ubuntu operating system must disable the x86 Ctrl-Alt-Delete key sequence if a graphical user interface is installed.
    - dconf_gnome_disable_ctrlaltdel_reboot

    # UBTU-22-211015 The Ubuntu operating system must disable the x86 Ctrl-Alt-Delete key sequence.
    - disable_ctrlaltdel_reboot
    - disable_ctrlaltdel_burstaction

    # UBTU-22-291010 The Ubuntu operating system must disable automatic mounting of Universal Serial Bus (USB) mass storage driver.
    - kernel_module_usb-storage_disabled

    # UBTU-22-611065 The Ubuntu operating system must not have accounts configured with blank or null passwords.
    - no_empty_passwords_etc_shadow

    # UBTU-22-611060 The Ubuntu operating system must not allow accounts configured with blank or null passwords.
    - no_empty_passwords

    ### TODO (fix dconf issues)
    # UBTU-22-271025 must initiate a graphical session lock after 15 minutes of inactivity
    - inactivity_timeout_value=15_minutes
    - var_screensaver_lock_delay=immediate
    - dconf_gnome_screensaver_lock_delay
    - dconf_gnome_screensaver_idle_delay

    # UBTU-22-654220 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to modify the /etc/sudoers file occur
    - audit_rules_sudoers

    # UBTU-22-654225 The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to modify the /etc/sudoers.d directory occur
    - audit_rules_sudoers_d

    # UBTU-22-611055 The Ubuntu operating system must store only encrypted representations of passwords
    - set_password_hashing_algorithm_systemauth

    # UBTU-22-654190 The Ubuntu operating system must generate audit records for all events that affect the systemd journal files
    - audit_rules_var_log_journal

    # UBTU-22-215020 The Ubuntu operating system must not have the "systemd-timesyncd" package installed
    - package_timesyncd_removed

    # UBTU-22-215025 The Ubuntu operating system must not have the "ntp" package installed
    - package_ntp_removed

    ### TODO (reevaluate directory permissions)
    # UBTU-22-232027 The Ubuntu operating system must generate system journal entries without revealing information that could be exploited by adversaries
    - file_permissions_system_journal
    - dir_permissions_system_journal

    ### TODO (incomplete remediation - tmpfiles.d)
    # UBTU-22-232080 The Ubuntu operating system must configure the directories used by the system journal to be owned by "root"
    - dir_owner_system_journal

    ### TODO (incomplete remediation - tmpfiles.d)
    # UBTU-22-232085 The Ubuntu operating system must configure the directories used by the system journal to be group-owned by "systemd-journal"
    - dir_groupowner_system_journal


    ### TODO (incomplete remediation - tmpfiles.d)
    # UBTU-22-232090 The Ubuntu operating system must configure the files used by the system journal to be owned by "root"
    - file_owner_system_journal

    ### TODO (incomplete remediation - tmpfiles.d)
    # UBTU-22-232095 The Ubuntu operating system must configure the files used by the system journal to be group-owned by "systemd-journal"
    - file_groupowner_system_journal

    # UBTU-22-232100 The Ubuntu operating system must be configured so that the "journalctl" command is owned by "root"
    - file_owner_journalctl

    # UBTU-22-232105 The Ubuntu operating system must be configured so that the "journalctl" command is group-owned by "root"
    - file_groupowner_journalctl

    # UBTU-22-232140 The Ubuntu operating system must be configured so that the "journalctl" command is not accessible by unauthorized users
    - file_permissions_journalctl
