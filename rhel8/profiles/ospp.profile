documentation_complete: true

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2).

selections:
    #################################################################
    ## BOOT
    #################################################################

    ## RHEL 8 CCE-80829-5: Set the UEFI Boot Loader Password
    - grub2_uefi_password


    #################################################################
    ## Systemd Items
    #################################################################

    ## RHEL 8 CCE-80855-0: Require Authentication for Single User Mode
    - require_singleuser_auth

    ## RHEL 8 CCE-80826-1: Verify that Interactive Boot is Disabled
    - grub2_disable_interactive_boot

    ## RHEL 8 CCE-80785-9: Disable Ctrl-Alt-Del Reboot Activation
    - disable_ctrlaltdel_reboot

    ## RHEL 8 CCE-80784-2: Disable Ctrl-Alt-Del Burst Action
    - disable_ctrlaltdel_burstaction

    ## RHEL 8 CCE-80876-6: Disable debug-shell SystemD Service
    - service_debug-shell_disabled

    # TODO: Storage=none in /etc/systemd/coredump.conf
    # TODO: ProcessSizeMax=0 in  /etc/systemd/coredump.conf
    # TODO: systemctl mask systemd-coredump.socket


    #################################################################
    ## Partitioning
    #################################################################

    #part /boot --fstype=xfs --size=512 --fsoptions="nodev,nosuid"

    ## RHEL 8 CCE-82941-6: Add nodev Option to /boot
    - mount_option_boot_nodev

    ## RHEL 8 CCE-81033-3: Add nosuid Option to /boot
    - mount_option_boot_nosuid

    #logvol /home --fstype=xfs --name=home --vgname=VolGroup --size=1024 --fsoptions="nodev,nosuid"

    ## RHEL 8 CCE-81044-0: Ensure /home Located On Separate Partition
    - partition_for_home

    ## RHEL 8 CCE-81048-1: Add nodev Option to /home
    - mount_option_home_nodev

    ## RHEL 8 CCE-81050-7: Add nosuid Option to /home
    - mount_option_home_nosuid

    ## RHEL 8 CCE-81126-5: Add nodev Option to /tmp
    - mount_option_tmp_nodev

    ## RHEL 8 CCE-81127-3: Add noexec Option to /tmp
    - mount_option_tmp_noexec

    ## RHEL 8 CCE-81128-1: Add nosuid Option to /tmp
    - mount_option_tmp_nosuid

    # logvol /var --fstype=xfs --name=var --vgname=VolGroup --size=2048 --fsoptions="nodev"

    ## RHEL 8 CCE-80852-7: Ensure /var Located On Separate Partition
    - partition_for_var

    ## RHEL 8 CCE-81013-5: Add nodev Option to /var
    - mount_option_var_nodev

    # logvol /var/log --fstype=xfs --name=log --vgname=VolGroup --size=1024 --fsoptions="nodev,nosuid,noexec"

    ## RHEL 8 CCE-80853-5: Ensure /var/log Located On Separate Partition
    - partition_for_var_log

    ## RHEL 8 CCE-81079-6: Add nodev Option to /var/log
    - mount_option_var_log_nodev

    ## RHEL 8 CCE-82008-4: Add noexec Option to /var/log
    - mount_option_var_log_noexec

    ## RHEL 8 CCE-81016-8: Add nosuid Option to /var/log
    - mount_option_var_log_nosuid

    # logvol /var/log/audit --fstype=xfs --name=audit --vgname=VolGroup --size=512 --fsoptions="nodev,nosuid,noexec"

    ## RHEL 8 CCE-80854-3: Ensure /var/log/audit Located On Separate Partition
    - partition_for_var_log_audit

    ## RHEL 8 CCE-81095-2: Add nodev Option to /var/log/audit
    - mount_option_var_log_audit_nodev

    ## RHEL 8 CCE-82975-4: Add noexec Option to /var/log/audit
    - mount_option_var_log_audit_noexec

    ## RHEL 8 CCE-82921-8: Add nosuid Option to /var/log/audit
    - mount_option_var_log_audit_nosuid

    # logvol /var/tmp --fstype=xfs --name=vartmp --vgname=VolGroup --size=1024 --fsoptions="nodev,nosuid,noexec"

    ## RHEL 8 CCE-82846-7: Ensure /var/tmp Located On Separate Partition
    - partition_for_var_tmp

    ## RHEL 8 CCE-81053-1: Add nodev Option to /var/tmp
    - mount_option_var_tmp_nodev

    ## RHEL 8 CCE-81129-9: Add noexec Option to /var/tmp
    - mount_option_var_tmp_noexec

    ## RHEL 8 CCE-81131-5: Add nosuid Option to /var/tmp
    - mount_option_var_tmp_nosuid

    ## RHEL 8 CCE-80837-8: Add nodev Option to /dev/shm
    - mount_option_dev_shm_nodev

    ## RHEL 8 CCE-80838-6: Add noexec Option to /dev/shm
    - mount_option_dev_shm_noexec

    ## RHEL 8 CCE-80839-4: Add nosuid Option to /dev/shm
    - mount_option_dev_shm_nosuid


    #################################################################
    ## KERNEL CONFIGURATION
    #################################################################

    #################################################################
    ## Boot Prompt Configuration
    #################################################################

    ## RHEL 8 CCE-81132-3: Enable Dracut FIPS Module
    - enable_dracut_fips_module

    ## RHEL 8 CCE-80942-6: Enable FIPS Mode
    - enable_fips_mode

    ## RHEL 8 CCE-80825-3: Enable Auditing for Processes Which Start Prior to the Audit Daemon
    - grub2_audit_argument

    ## RHEL 8 CCE-80825-3: Extend Audit Backlog Limit for the Audit Daemon
    - grub2_audit_backlog_limit_argument

    ## RHEL 8 CCE-80945-9: Enable SLUB/SLAB allocator poisoning
    - grub2_slub_debug_argument

    ## RHEL 8 CCE-80944-2: Enable page allocator poisoning
    - grub2_page_poison_argument

    # TODO:
    # - grub2_pti_argument

    ## RHEL 8 CCE-80946-7: Disable vsyscalls
    - grub2_vsyscall_argument

    # TODO:
    # boot=/dev/something


    #################################################################
    ## Kernel Security Settings
    #################################################################

    ## RHEL 8 CCE-80915-2: Restrict Exposed Kernel Pointer Addresses Access
    - sysctl_kernel_kptr_restrict

    ## RHEL 8 CCE-80913-7: Restrict Access to Kernel Message Buffer
    - sysctl_kernel_dmesg_restrict

    ## RHEL 8 CCE-81054-9: Disallow kernel profiling by unprivileged users
    - sysctl_kernel_perf_event_paranoid

    ## RHEL 8 CCE-80952-5: Disable Kernel Image Loading
    - sysctl_kernel_kexec_load_disabled

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4492
    #echo "# If you know you are have containers that need user namespaces," >> $CONFIG
    #echo "# you MAY comment out the next line." >> $CONFIG
    #echo "user.max_user_namespaces = 0" >> $CONFIG
    #- sysctl_user_max_user_namespaces

    ## RHEL 8 CCE-80953-3: Restrict Usage of ptrace To Descendant Processes
    - sysctl_kernel_yama_ptrace_scope

    ## RHEL 8 CCE-82974-7: Disable access to network bpf() syscall from unprivileged processes
    - sysctl_kernel_unprivileged_bpf_disabled

    ## RHEL 8 CCE-82934-1: Harden the operation of the BPF just-in-time compiler
    - sysctl_net_core_bpf_jit_harden


    #################################################################
    ## File System Settings
    #################################################################

    ## RHEL 8 CCE-81027-5: Enable Kernel Parameter to Enforce DAC on Hardlinks
    - sysctl_fs_protected_hardlinks

    ## RHEL 8 CCE-81030-9: Enable Kernel Parameter to Enforce DAC on Symlinks
    - sysctl_fs_protected_symlinks

    # TODO:
    # echo "kernel.core_pattern=|/bin/false" >> $CONFIG


    #################################################################
    ## Network Settings
    #################################################################

    ## RHEL 8 CCE-81006-9: Disable Accepting Router Advertisements on All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_ra

    ## RHEL 8 CCE-81007-7: Disable Accepting Router Advertisements on All IPv6 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_ra

    ## RHEL 8 CCE-80917-8: Disable Accepting ICMP Redirects for All IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_redirects

    ## RHEL 8 CCE-80919-4: Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
    - sysctl_net_ipv4_conf_default_accept_redirects

    ## RHEL 8 CCE-81009-3: Disable Accepting ICMP Redirects for All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_redirects

    ## RHEL 8 CCE-81010-1: Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces
    - sysctl_net_ipv6_conf_default_accept_redirects

    ## RHEL 8 CCE-81011-9: Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_source_route

    ## RHEL 8 CCE-80920-2: Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_accept_source_route

    ## RHEL 8 CCE-82182-7: Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_source_route

    ## RHEL 8 CCE-81015-0: Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_source_route

    ## RHEL 8 CCE-82465-6: Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_secure_redirects

    ## RHEL 8 CCE-81017-6: Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_secure_redirects

    ## RHEL 8 CCE-80918-6: Disable Kernel Parameter for Sending ICMP Redirects on all IPv4  Interfaces
    - sysctl_net_ipv4_conf_all_send_redirects

    ## RHEL 8 CCE-80921-0: Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_send_redirects

    ## RHEL 8 CCE-81018-4: Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_log_martians

    ## RHEL 8 CCE-81020-0: Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_log_martians

    ## RHEL 8 CCE-81021-8: Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_rp_filter

    ## RHEL 8 CCE-81022-6: Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_rp_filter

    ## RHEL 8 CCE-81023-4: Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ## RHEL 8 CCE-80922-8: Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ## RHEL 8 CCE-81024-2: Disable Kernel Parameter for IP Forwarding on IPv4 Interfaces
    - sysctl_net_ipv4_ip_forward

    ## RHEL 8 CCE-80923-6: Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces
    - sysctl_net_ipv4_tcp_syncookies


    #################################################################
    ## Blacklist Risky Kernel Modules
    #################################################################

    ## RHEL 8 CCE-82005-0: Disable IEEE 1394 (FireWire) Support
    - kernel_module_firewire-core_disabled

    ## RHEL 8 CCE-81031-7: Disable Mounting of cramfs
    - kernel_module_cramfs_disabled

    ## RHEL 8 CCE-82028-2: Disable ATM Support
    - kernel_module_atm_disabled

    ## RHEL 8 CCE-80832-9: Disable Bluetooth Kernel Module
    - kernel_module_bluetooth_disabled

    ## RHEL 8 CCE-82059-7: Disable CAN Support
    - kernel_module_can_disabled

    ## RHEL 8 CCE-80834-5: Disable SCTP Support
    - kernel_module_sctp_disabled

    # TO DO: https://github.com/ComplianceAsCode/content/issues/4458
    ## echo -e "install ticp /bin/true" >> $CONFIG


    #################################################################
    ## AUDIT
    #################################################################

    ## RHEL 8 CCE-80872-5: Enable auditd Service
    - service_auditd_enabled


    #################################################################
    ## 10-base-config.rules
    #################################################################

    # TODO: -D

    # TODO: -b 8192

    # TODO: --backlog_wait_time 60000

    # TODO: -f 1


    #################################################################
    ## 11-loginuid.rules
    #################################################################

    # TODO: --loginuid-immutable


    #################################################################
    ## 30-ospp-v42.rules
    #################################################################

    ## RHEL 8 CCE-80962-4: Record Unsuccessful Creation Attempts to Files - openat O_CREAT
    - audit_rules_unsuccessful_file_modification_openat_o_creat

    ## RHEL 8 CCE-80965-7: Record Unsuccessful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat

    ## RHEL 8 CCE-80968-1: Record Unsuccessful Creation Attempts to Files - open O_CREAT
    - audit_rules_unsuccessful_file_modification_open_o_creat

    ## RHEL 8 CCE-80751-1: Record Unsuccessful Access Attempts to Files - creat
    - audit_rules_unsuccessful_file_modification_creat

    ## RHEL 8 CCE-80963-2: Record Unsuccessful Modification Attempts to Files - openat O_TRUNC
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write

    ## RHEL 8 CCE-80966-5: Record Unsuccessful Modification Attempts to Files - open_by_handle_at O_TRUNC
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write

    ## RHEL 8 CCE-80969-9: Record Unsuccessful Modification Attempts to Files - open O_TRUNC
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write

    ## RHEL 8 CCE-80756-0: Record Unsuccessful Access Attempts to Files - truncate
    - audit_rules_unsuccessful_file_modification_truncate

    ## RHEL 8 CCE-80752-9: Record Unsuccessful Access Attempts to Files - ftruncate
    - audit_rules_unsuccessful_file_modification_ftruncate

    ## RHEL 8 CCE-80753-7: Record Unsuccessful Access Attempts to Files - open
    - audit_rules_unsuccessful_file_modification_open

    ## RHEL 8 CCE-80754-5: Record Unsuccessful Access Attempts to Files - openat
    - audit_rules_unsuccessful_file_modification_openat

    ## RHEL 8 CCE-80755-2: Record Unsuccessful Access Attempts to Files - open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ## RHEL 8 CCE-80971-5: Record Unsuccessful Delete Attempts to Files - unlink
    - audit_rules_unsuccessful_file_modification_unlink

    ## RHEL 8 CCE-80972-3: Record Unsuccessful Delete Attempts to Files - unlinkat
    - audit_rules_unsuccessful_file_modification_unlinkat

    ## RHEL 8 CCE-80973-1: Record Unsuccessful Delete Attempts to Files - rename
    - audit_rules_unsuccessful_file_modification_rename

    ## RHEL 8 CCE-80974-9: Record Unsuccessful Delete Attempts to Files - renameat
    - audit_rules_unsuccessful_file_modification_renameat

    ## RHEL 8 CCE-80975-6: Record Unsuccessul Permission Changes to Files - chmod
    - audit_rules_unsuccessful_file_modification_chmod

    ## RHEL 8 CCE-80977-2: Record Unsuccessul Permission Changes to Files - fchmod
    - audit_rules_unsuccessful_file_modification_fchmod

    ## RHEL 8 CCE-80976-4: Record Unsuccessul Permission Changes to Files - fchmodat
    - audit_rules_unsuccessful_file_modification_fchmodat

    ## RHEL 8 CCE-80983-0: Record Unsuccessul Permission Changes to Files - setxattr
    - audit_rules_unsuccessful_file_modification_setxattr

    ## RHEL 8 CCE-80981-4: Record Unsuccessul Permission Changes to Files - lsetxattr
    - audit_rules_unsuccessful_file_modification_lsetxattr

    ## RHEL 8 CCE-80979-8: Record Unsuccessul Permission Changes to Files - fsetxattr
    - audit_rules_unsuccessful_file_modification_fsetxattr

    ## RHEL 8 CCE-80982-2: Record Unsuccessul Permission Changes to Files - removexattr
    - audit_rules_unsuccessful_file_modification_removexattr

    ## RHEL 8 CCE-80980-6: Record Unsuccessul Permission Changes to Files - lremovexattr
    - audit_rules_unsuccessful_file_modification_lremovexattr

    ## RHEL 8 CCE-80978-0: Record Unsuccessul Permission Changes to Files - fremovexattr
    - audit_rules_unsuccessful_file_modification_fremovexattr

    ## RHEL 8 CCE-80987-1: Record Unsuccessul Ownership Changes to Files - lchown
    - audit_rules_unsuccessful_file_modification_lchown

    ## RHEL 8 CCE-80986-3: Record Unsuccessul Ownership Changes to Files - fchown
    - audit_rules_unsuccessful_file_modification_fchown

    ## RHEL 8 CCE-80984-8: Record Unsuccessul Ownership Changes to Files - chown
    - audit_rules_unsuccessful_file_modification_chown

    ## RHEL 8 CCE-80985-5: Record Unsuccessul Ownership Changes to Files - fchownat
    - audit_rules_unsuccessful_file_modification_fchownat

    ## RHEL 8 CCE-80931-9: Record Events that Modify User/Group Information via openat syscall - /etc/passwd
    - audit_rules_etc_passwd_openat

    ## RHEL 8 CCE-80932-7: Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/passwd
    - audit_rules_etc_passwd_open_by_handle_at

    ## RHEL 8 CCE-80930-1: Record Events that Modify User/Group Information via open syscall - /etc/passwd
    - audit_rules_etc_passwd_open

    ## RHEL 8 CCE-80958-2: Record Events that Modify User/Group Information via openat syscall - /etc/shadow
    - audit_rules_etc_shadow_openat

    ## RHEL 8 CCE-80957-4: Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/shadow
    - audit_rules_etc_shadow_open_by_handle_at

    ## RHEL 8 CCE-80956-6: Record Events that Modify User/Group Information via open syscall - /etc/shadow
    - audit_rules_etc_shadow_open

    ## RHEL 8 CCE-80928-5: Record Events that Modify User/Group Information via openat syscall - /etc/group
    - audit_rules_etc_group_openat

    ## RHEL 8 CCE-80929-3: Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/group
    - audit_rules_etc_group_open_by_handle_at

    ## RHEL 8 CCE-80927-7: Record Events that Modify User/Group Information via open syscall - /etc/group
    - audit_rules_etc_group_open

    ## RHEL 8 CCE-80961-6: Record Events that Modify User/Group Information via openat syscall - /etc/gshadow
    - audit_rules_etc_gshadow_openat

    ## RHEL 8 CCE-80960-8: Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/gshadow
    - audit_rules_etc_gshadow_open_by_handle_at

    ## RHEL 8 CCE-80959-0: Record Events that Modify User/Group Information via open syscall - /etc/gshadow
    - audit_rules_etc_gshadow_open

    ## RHEL 8 CCE-80740-4" Ensure auditd Collects Information on the Use of Privileged Commands - unix_chkpwd
    - audit_rules_privileged_commands_unix_chkpwd

    ## RHEL 8 CCE-80990-5: Ensure auditd Collects Information on the Use of Privileged Commands - usernetctl
    - audit_rules_privileged_commands_usernetctl

    ## RHEL 8 CCE-80741-2: Ensure auditd Collects Information on the Use of Privileged Commands - userhelper
    - audit_rules_privileged_commands_userhelper

    ## RHEL 8 CCE-80933-5: Record Any Attempts to Run seunshare
    - audit_rules_execution_seunshare

    ## RHEL 8 CCE-80989-7: Ensure auditd Collects Information on the Use of Privileged Commands - mount
    - audit_rules_privileged_commands_mount

    ## RHEL 8 CCE-80729-7: Ensure auditd Collects Information on the Use of Privileged Commands - newgrp
    - audit_rules_privileged_commands_newgrp

    ## RHEL 8 CCE-80992-1: Ensure auditd Collects Information on the Use of Privileged Commands - newuidmap
    - audit_rules_privileged_commands_newuidmap

    ## RHEL 8 CCE-80728-9: Ensure auditd Collects Information on the Use of Privileged Commands - gpasswd
    - audit_rules_privileged_commands_gpasswd

    ## RHEL 8 CCE-80991-3: Ensure auditd Collects Information on the Use of Privileged Commands - newgidmap
    - audit_rules_privileged_commands_newgidmap

    ## RHEL 8 CCE-80739-6: Ensure auditd Collects Information on the Use of Privileged Commands - umount
    - audit_rules_privileged_commands_umount

    ## RHEL 8 CCE-80731-3: Ensure auditd Collects Information on the Use of Privileged Commands - passwd
    - audit_rules_privileged_commands_passwd

    ## RHEL 8 CCE-80727-1: Ensure auditd Collects Information on the Use of Privileged Commands - crontab
    - audit_rules_privileged_commands_crontab

    ## RHEL 8 CCE-80988-9: Ensure auditd Collects Information on the Use of Privileged Commands - at
    - audit_rules_privileged_commands_at

    ## RHEL 8 CCE-80941-8: Record Access Events to Audit Log Directory
    - directory_access_var_log_audit


    #################################################################
    ## 43-module-load.rules
    #################################################################

    ## RHEL 8 CCE-80713-1: Ensure auditd Collects Information on Kernel Module Loading - init_module
    - audit_rules_kernel_module_loading_init

    ## RHEL 8 CCE-80712-3: Ensure auditd Collects Information on Kernel Module Loading - finit_module
    - audit_rules_kernel_module_loading_finit

    ## RHEL 8 CCE-80711-5: Ensure auditd Collects Information on Kernel Module Loading - delete_module
    - audit_rules_kernel_module_loading_delete


    #################################################################
    ## Audit Configuration
    #################################################################

    # TODO: local_events=YES

    # TODO: write_logs=YES

    # TODO: log_format=ENRICHED

    ## RHEL 8 CCE-80680-2: Configure auditd flush priority
    - auditd_data_retention_flush
    - var_auditd_flush=incremental_async

    # TODO: freq=50

    # TODO: name_format=HOSTNAME


    #################################################################
    ## Audispd plugins
    #################################################################

    ## RHEL 8 CCE-80677-8: Configure auditd to use audispd's syslog plugin
    - auditd_audispd_syslog_plugin_activated


    #################################################################
    ## SERVICES
    #################################################################

    #################################################################
    ## SSH Server
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4466
    #sed -i "/ed25519/s/HostKey/#HostKey/" $CONFIG

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4467
    #sed -i "s/#RekeyLimit default none/RekeyLimit 512M/" $CONFIG

    ## RHEL 8 CCE-80901-2: Disable SSH Root Login
    - sshd_disable_root_login

    ## RHEL 8 CCE-80904-6: Enable Use of Strict Mode Checking
    - sshd_enable_strictmodes

    ## RHEL 8 CCE-80786-7: Disable Host-Based Authentication
    - disable_host_auth

    ## RHEL 8 CCE-80902-0: Disable SSH Support for User Known Hosts
    - sshd_disable_user_known_hosts

    ## RHEL 8 CCE-80899-8: Disable SSH Support for .rhosts Files
    - sshd_disable_rhosts

    ## RHEL 8 CCE-80896-4: Disable SSH Access via Empty Passwords
    - sshd_disable_empty_passwords

    ## RHEL 8 CCE-80898-0: Disable Kerberos Authentication
    - sshd_disable_kerb_auth

    ## RHE 8 CCE-80897-2: Disable GSSAPI Authentication
    - sshd_disable_gssapi_auth

    ## RHEL 8 CCE-80906-1: Set SSH Idle Timeout Interval
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    ## RHEL 8 CCE-80907-9: Set SSH Client Alive Max Count
    - var_sshd_set_keepalive=0
    - sshd_set_keepalive

    ## RHEL 8 CCE-80905-3: Enable SSH Warning Banner
    # - sshd_enable_warning_banner
    ## TO DO - Needs customization of path
    #echo -e "\nReplace this with your organization-defined system use notification message or banner\n" > /etc/issue
    #cp /etc/issue /etc/issue.net
    #sed -i "s/#Banner none/Banner \/etc\/issue.net/" $CONFIG

    # TODO: Ciphers aes128-ctr,aes256-ctr,aes128-cbc,aes256-cbc
    # TODO: PubkeyAcceptedKeyTypes ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384
    # TODO: MACs hmac-sha2-256,hmac-sha2-512
    # TODO: KexAlgorithms diffie-hellman-group14-sha1,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
    # - configure_ssh_crypto_policy
    # - var_system_crypto_policy=<POLICY>


    #################################################################
    ## SSH Client
    #################################################################

    # TODO: HostbasedAuthentication no

    # TODO: GSSAPIAuthentication no

    # TODO: RekeyLimit 512M 1h

    # TODO: Ciphers aes256-ctr,aes256-cbc,aes128-ctr,aes128-cbc
    # should be handled by crypto-policies

    # TODO: PubkeyAcceptedKeyTypes ssh-rsa,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
    # should be handled by crypto-policies

    # TODO: MACs hmac-sha2-512,hmac-sha2-256 <- order matters
    # should be handled by crypto-policies

    # TODO: KexAlgorithms ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group14-sha1
    # should be handled by crypto-policies


    #################################################################
    ## Firewall
    #################################################################

    ## RHEL 8 CCE-82883-0: Install firewalld
    - package_firewalld_installed

    ## RHEL 8 CCE-80877-4: Verify firewalld Enabled
    - service_firewalld_enabled


    #################################################################
    ## abrt
    #################################################################

    ## RHEL 8 CCE-80948-3: Uninstall Automatic Bug Reporting Tool (abrt)
    - package_abrt_removed


    #################################################################
    ## Chrony (time server)
    #################################################################

    ## RHEL 8 CCE-82988-7: Disable chrony daemon from acting as server
    - chronyd_client_only

    ## RHEL 8 CCE-82840-0: Disable network management of chrony daemon
    - chronyd_no_chronyc_network


    #################################################################
    ## Enable rngd Service
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4472
    #sysctl enable rngd.service


    #################################################################
    ## sssd Settings
    #################################################################

    ## RHEL 8 CCE-82940-8: Install the SSSD Package
    - package_sssd_installed

    ## RHEL 8 CCE-81062-2: Configure SSSD to run as user sssd
    - sssd_run_as_sssd_user

    # - sssd_memcache_timeout - removed, because non-security

    # - sssd_offline_cred_expiration - removed, because non-security

    # TODO:  Set system name that manages settings

    #################################################################
    ## Crypto settings
    #################################################################


    #################################################################
    ## Libreswan Setup
    #################################################################

    ## RHEL 8 CCE-80845-1: Install libreswan Package
    - package_libreswan_installed

    # FIXME: Need to talk to Paul about generic server/client setups
    # And for servers, need to punch holes in firewall


    #################################################################
    ## Application Whitelisting
    #################################################################

    # TODO: fapolicyd installed

    # TODO: fapolicyd enabled

    # TODO: System default policy (no changes)


    #################################################################
    ## Harden USB Guard
    #################################################################

    # TODO: usbguard installed

    # TODO: usbguard enabled
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4474
    #systemctl enable usbguard

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4473
    #sed -i "/AuditBackend/s/FileAudit/LinuxAudit/" /etc/usbguard/usbguard-daemon.conf


    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4496
    #cat << EOF > /tmp/rules.conf
    #allow with-interface equals { 09:00:* }
    #allow with-interface equals { 03:*:* }
    #allow with-interface equals { 03:*:* 03:*:* }
    #EOF
    #}

    #setup_usbguard () {
    #    chmod 0600 /tmp/rules.conf
    #    mv /tmp/rules.conf /etc/usbguard/
    #    restorecon -R /etc/usbguard/
    #}


    #################################################################
    ## USER SESSIONS
    #################################################################

    #################################################################
    ## Login
    #################################################################

    ## RHEL 8 CCE-80841-0: Prevent Login to Accounts With Empty Password
    - no_empty_passwords

    ## RHEL 8 CCE-80667-9: Set Deny For Failed Password Attempts
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny

    ## RHEL 8 CCE-80669-5: Set Interval For Counting Failed Password Attempts
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval

    ## RHEL 8 CCE-80670-3: Set Lockout Time for Failed Password Attempts
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time

    ## RHEL 8 CCE-80768-5: Enable GNOME3 Login Warning Banner
    - dconf_gnome_banner_enabled

    ## RHEL 8 CCE-80770-1: Set the GNOME3 Login Warning Banner Text
    - login_banner_text=usgcb_default
    - dconf_gnome_login_banner_text

    ## RHEL 8 CCE-81038-2: Disable Core Dumps for All Users
    - disable_users_coredumps

    ## RHEL 8 CCE-80955-8: Limit the Number of Concurrent Login Sessions Allowed Per User
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions

    ## RHEL 8 CCE-80666-1: Limit Password Reuse
    - accounts_password_pam_unix_remember
    - var_password_pam_unix_remember=5


    #################################################################
    ## Password
    #################################################################

    ## RHEL 8 CCE-80841-0: Prevent Login to Accounts With Empty Password
    # - no_empty_passwords - duplicate

    ## RHEL 8 CCE-80652-1: Set Password Minimum Length in login.defs
    - var_accounts_password_minlen_login_defs=12
    - accounts_password_minlen_login_defs

    ## RHEL 8 CCE-80656-2: Ensure PAM Enforces Password Requirements - Minimum Length
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen

    ## RHEL 8 CCE-80663-8: Ensure PAM Enforces Password Requirements - Minimum Special Characters
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ## RHEL 8 CCE-80653-9: Minimum Digit Characters
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ## RHEL 8 CCE-80665-3: Ensure PAM Enforces Password Requirements - Minimum Uppercase Characters
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ## RHEL 8 CCE-80655-4: Ensure PAM Enforces Password Requirements - Minimum Lowercase Characters
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ## RHEL 8 CCE-80654-7: Ensure PAM Enforces Password Requirements - Minimum Different Characters
    - var_password_pam_difok=4
    - accounts_password_pam_difok

    ## RHEL 8 CCE-81034-1: Set Password Maximum Consecutive Repeating Characters
    - var_password_pam_maxrepeat=3
    - accounts_password_pam_maxrepeat

    ## RHEL 8 CCE-81034-1: Ensure PAM Enforces Password Requirements - Maximum Consecutive Repeating Characters from Same Character Class
    - var_password_pam_maxclassrepeat=4
    - accounts_password_pam_maxclassrepeat


    #################################################################
    ## umask
    #################################################################

    ## Set umask Variable for next few rules
    - var_accounts_user_umask=027

    ## RHEL 8 CCE-81035-8: Ensure the Default Umask is Set Correctly in /etc/profile
    - accounts_umask_etc_profile

    ## RHEL 8 CCE-81036-6: Ensure the Default Bash Umask is Set Correctly
    - accounts_umask_etc_bashrc

    ## RHEL 8 CCE-81037-4: Ensure the Default C Shell Umask is Set Correctly
    - accounts_umask_etc_csh_cshrc


    #################################################################
    ## Console Screen Lock
    #################################################################

    ## RHEL 8 CCE-80644-8: Install the tmux Package
    - package_tmux_installed

    # TODO: "/etc/bashrc has [[ $TERM != ""screen"" ]] && exec tmux"

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4498
    #set -g lock-after-time 900

    ## RHEL 8 CCE-80940-0: Configure the tmux Lock Command
    - configure_tmux_lock_command

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4499
    #set -g status off


    #################################################################
    ## Software Updates
    #################################################################

    ## TODO: dnf-automatic installed

    ## TODO: dnf-automatic enabled

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4477
    #sed -i "/apply_updates/s/no/yes/" /etc/dnf/automatic.conf

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4478
    #systemctl enable --now dnf-automatic.timer

    ## RHEL 8 CCE-80795-8: Ensure Red Hat GPG Key Installed
    - ensure_redhat_gpgkey_installed

    ## RHEL 8 CCE-80790-9: Ensure gpgcheck Enabled In Main yum Configuration
    - ensure_gpgcheck_globally_activated

    ## RHEL 8 CCE-80791-7: Ensure gpgcheck Enabled for Local Packages
    - ensure_gpgcheck_local_packages

    ## RHEL 8 CCE-80792-5: Ensure gpgcheck Enabled for All yum Package Repositories
    - ensure_gpgcheck_never_disabled
