documentation_complete: true

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2).

selections:

    #################################################################
    ## SELinux Configuration
    #################################################################

    ## Ensure SELinux is Enforcing
    - var_selinux_state=enforcing
    - selinux_state

    ## Configure SELinux Policy
    - var_selinux_policy_name=targeted
    - selinux_policytype


    #################################################################
    ## Bootloader Configuration
    #################################################################
    #TO DO: bootloader --location=mbr --append="boot=/dev/vda1 fips=1 "

    ## Set the UEFI Boot Loader Password
    - grub2_uefi_password

    ## Require Authentication for Single User Mode
    - require_singleuser_auth

    ## Verify that Interactive Boot is Disabled
    - grub2_disable_interactive_boot

    ## Enable Auditing for Processes Which Start Prior to the Audit Daemon
    - grub2_audit_argument

    ## Extend Audit Backlog Limit for the Audit Daemon
    - grub2_audit_backlog_limit_argument

    ## Enable SLUB/SLAB allocator poisoning
    - grub2_slub_debug_argument

    ## Enable page allocator poisoning
    - grub2_page_poison_argument

    ## Enable Kernel Page-Table Isolation (KPTI)
    - grub2_pti_argument

    ## Disable vsyscalls
    - grub2_vsyscall_argument


    #################################################################
    ## Partitioning Configuration
    #################################################################

    ###########
    ## /boot
    ###########
    # TO DO: /boot on its own partition?!

    ## Add nodev Option to /boot
    - mount_option_boot_nodev

    ## Add nosuid Option to /boot
    - mount_option_boot_nosuid

    ###########
    ## /home
    ###########

    ## Ensure /home Located On Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4484
    ##  unclear if partition requirements still relevant
    - partition_for_home

    ## Add nodev Option to /home
    - mount_option_home_nodev

    ## Add nosuid Option to /home
    - mount_option_home_nosuid

    ###########
    ## /var
    ###########

    ## Ensure /var Located on Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4486
    ##  unclear if partition requirements still exist
    - partition_for_var

    ## Add nodev Option to /var
    - mount_option_var_nodev

    ###########
    ## /var/log
    ###########

    ## Ensure /var/log Located on Separate Partition
    - partition_for_var_log

    ## Add nodev Option to /var/log
    - mount_option_var_log_nodev

    ## Add nosuid Option to /var/log
    - mount_option_var_log_nosuid

    ## Add noexec Option to /var/log
    - mount_option_var_log_noexec

    ###########
    ## /var/log/audit
    ###########
    ## Ensure /var/log/audit Located on Separate Partition
    - partition_for_var_log_audit

    ## Add nodev Option to /var/log/audit
    - mount_option_var_log_audit_nodev

    ## Add nosuid Option to /var/log/audit
    - mount_option_var_log_audit_nosuid

    ## Add noexec Option to /var/log/audit
    - mount_option_var_log_audit_noexec

    ###########
    ## /var/tmp
    ###########

    ## Add nodev Option to /var/tmp
    - mount_option_var_tmp_nodev

    ## Add nosuid Option to /var/tmp
    - mount_option_var_tmp_nosuid

    ## Add noexec Option to /var/tmp
    - mount_option_var_tmp_noexec

    ###########
    ## /tmp
    ###########

    ## Setup a couple mountpoints by hand to ensure correctness
    #touch /etc/fstab
    ## Ensure /tmp Located On Separate Partition
    #echo -e "tmpfs\t/tmp\t\t\t\ttmpfs\tdefaults,mode=1777,,,nodev,strictatime,size=512M\t0 0" >> /etc/fstab

    ## Add nodev Option to /tmp
    - mount_option_tmp_nodev

    ## Add noexec Option to /tmp
    - mount_option_tmp_noexec

    ## Add nosuid Option to /tmp
    - mount_option_tmp_nosuid

    ###########
    ## /swap
    ###########
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4490
    ##  do we need a swap partition (for security reasons)?
    #logvol swap --name=lv_swap --vgname=VolGroup --size=2016

    ###########
    ## /dev/shm
    ###########
    ## Make sure /dev/shm is restricted
    #echo -e "tmpfs\t/dev/shm\t\t\t\ttmpfs\tdefaults,mode=1777,,,strictatime\t0 0" >> /etc/fstab

    ## Add nodev Option to /dev/shm
    - mount_option_dev_shm_nodev

    ## Add noexec Option to /dev/shm
    - mount_option_dev_shm_noexec

    ## Add nosuid Option to /dev/shm
    - mount_option_dev_shm_nosuid

    ###########
    ## Misc Partitioning
    ###########
    ## Add nodev Option to Non-Root Local Partitions
    - mount_option_nodev_nonroot_local_partitions

    #################################################################
    ## Required Packages
    #################################################################

    ## Install sssd-ipa Package
    - package_sssd-ipa_installed

    ## Install aide Package
    - package_aide_installed

    ## Install dnf-automatic Package
    - package_dnf-automatic_installed

    ## Install firewalld Package
    - package_firewalld_installed

    ## Install iptables Package
    - package_iptables_installed

    ## Install libcap-ng-utils Package
    - package_libcap-ng-utils_installed

    ## Install openscap-scanner Package
    - package_openscap-scanner_installed

    ## Install policycoreutils Package
    - package_policycoreutils_installed

    ## Install python-rhsm Package
    - package_python-rhsm_installed

    ## Install rng-tools Package
    - package_rng-tools_installed

    ## Install sudo Package
    - package_sudo_installed

    ## Install tmux Package
    - package_tmux_installed

    ## Install usbguard Package
    - package_usbguard_installed

    ## Install audispd-plugins Package
    - package_audispd-plugins_installed

    ## Install scap-security-guide Package
    - package_scap-security-guide_installed

    ## Ensure the audit Subsystem is Installed
    - package_auditd_installed

    ## Install libreswan Package
    - package_libreswan_installed

    ## Ensure rsyslog is Installed
    - package_rsyslog_installed

    #################################################################
    ## Remove Prohibited Packages
    #################################################################

    ## Uninstall Sendmail Package
    - package_sendmail_removed

    ## Uninstall iprutils Package
    - package_iprutils_removed

    ## Uninstall gssproxy Package
    - package_gssproxy_removed

    ## Uninstall nfs-utils Package
    - package_nfs-utils_removed

    ## Uninstall krb5-workstation Package
    - package_krb5-workstation_removed

    ## Uninstall abrt-addon-kerneloops Package
    - package_abrt-addon-kerneloops_removed

    ## Uninstall abrt-addon-python Package
    - package_abrt-addon-python_removed

    ## Uninstall abrt-addon-ccpp Package
    - package_abrt-addon-ccpp_removed

    ## Uninstall abrt-plugin-rhtsupport Package
    - package_abrt-plugin-rhtsupport_removed

    ## Uninstall abrt-plugin-logger Package
    - package_abrt-plugin-logger_removed

    ## Uninstall abrt-plugin-sosreport Package
    - package_abrt-plugin-sosreport_removed

    ## Uninstall abrt-cli Package
    - package_abrt-cli_removed

    ## Uninstall tuned Package
    - package_tuned_removed

    ## Uninstall Automatic Bug Reporting Tool (abrt)
    - package_abrt_removed

    #################################################################
    ##
    ## Set PATH correctly
    ##
    #################################################################

    ## TO DO
    #PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH

    #################################################################
    ##
    ## Configure Audit Daemon
    ##
    #################################################################

    ## Enable auditd Service
    - service_auditd_enabled


    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Creation
    ## (open with O_CREAT)
    ##
    #################################################################

    ## Record Unsuccessful Creation Attempts to Files - openat O_CREAT
    - audit_rules_unsuccessful_file_modification_openat_o_creat

    ## Record Successful Creation Attempts to Files - opanat O_CREAT
    - audit_rules_successful_file_modification_openat_o_creat

    ## Record Unsuccessful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat

    ## Record Successful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_successful_file_modification_open_by_handle_at_o_creat

    ## Record Unsuccessful Creation Attempts to Files - open O_CREAT
    - audit_rules_unsuccessful_file_modification_open_o_creat

    ## Record Successful Creation Attempts to Files - open O_CREAT
    - audit_rules_successful_file_modification_open_o_creat

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Modifications
    ## (open for write or truncate with O_TRUNC_WRITE)
    ##
    #################################################################

    ## Record Unsuccessful Modification Attempts to Files - openat O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write

    ## Record Successful Modification Attempts to Files - openat O_TRUNC_WRITE
    - audit_rules_successful_file_modification_openat_o_trunc_write

    ## Record Unsuccessful Modification Attempts to Files - open_by_handle_at O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write

    ## Record Successful Modification Attempts to Files - open_by_handle_at O_TRUNC_WRITE
    - audit_rules_successful_file_modification_open_by_handle_at_o_trunc_write

    ## Record Unsuccessful Modification Attempts to Files - open O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write

    ## Record Successful Modification Attempts to Files - open O_TRUNC_WRITE
    - audit_rules_successful_file_modification_open_o_trunc_write

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Access
    ## (any other opens)
    ##
    ## This has to go last.
    ##
    #################################################################

    ## Record Unsuccessful Access Attempts to Files - open
    - audit_rules_unsuccessful_file_modification_open

    ## Record Successful Access Attempts to Files - open
    - audit_rules_successful_file_modification_open

    ## Record Unsuccessful Access Attempts to Files - creat
    - audit_rules_unsuccessful_file_modification_creat

    ## Record Successful Access Attempts to Files - creat
    - audit_rules_successful_file_modification_creat

    ## Record Unsuccessful Access Attempts to Files - truncate
    - audit_rules_unsuccessful_file_modification_truncate

    ## Record Successful Access Attempts to Files - truncate
    - audit_rules_successful_file_modification_truncate

    ## Record Unsuccessful Access Attempts to Files - ftruncate
    - audit_rules_unsuccessful_file_modification_ftruncate

    ## Record Successful Access Attempts to Files - ftruncate
    - audit_rules_successful_file_modification_ftruncate

    ## Record Unsuccessful Access Attempts to Files - openat
    - audit_rules_unsuccessful_file_modification_openat

    ## Record Successful Access Attempts to Files - openat
    - audit_rules_successful_file_modification_openat

    ## Record Unsuccessful Access Attempts to Files - open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ## Record Successful Access Attempts to Files - open_by_handle_at
    - audit_rules_successful_file_modification_open_by_handle_at

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Delete
    ##
    #################################################################

    ## Record Unsuccessful Delete Attempts to Files - unlink
    - audit_rules_unsuccessful_file_modification_unlink

    ## TO DO: Record Successful Delete Attempts to Files - unlink
    - audit_rules_successful_file_modification_unlink

    ## Record Unsuccessful Delete Attempts to Files - unlinkat
    - audit_rules_unsuccessful_file_modification_unlinkat

    ## TO DO: Record Successful Delete Attempts to Files - unlinkat
    - audit_rules_successful_file_modification_unlinkat

    ## Record Unsuccessful Delete Attempts to Files - rename
    - audit_rules_unsuccessful_file_modification_rename

    ## TO DO: Record Successful Delete Attempts to Files - rename
    - audit_rules_successful_file_modification_rename

    ## Record Unsuccessful Delete Attempts to Files - renameat
    - audit_rules_unsuccessful_file_modification_renameat

    ## TO DO: Record Successful Delete Attempts to Files - renameat
    - audit_rules_successful_file_modification_renameat

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Permission Change
    ##
    #################################################################

    ## Record Unsuccessul Permission Changes to Files - chmod
    - audit_rules_unsuccessful_file_modification_chmod

    ## Record Successful Permission Changes to Files - chmod
    - audit_rules_successful_file_modification_chmod

    ## Record Unsuccessul Permission Changes to Files - fchmod
    - audit_rules_unsuccessful_file_modification_fchmod

    ## Record Successful Permission Changes to Files - fchmod
    - audit_rules_successful_file_modification_fchmod

    ## Record Unsuccessul Permission Changes to Files - fchmodat
    - audit_rules_unsuccessful_file_modification_fchmodat

    ## Record Successful Permission Changes ot Files - fchmodat
    - audit_rules_successful_file_modification_fchmodat

    ## Record Unsuccessul Permission Changes to Files - setxattr
    - audit_rules_unsuccessful_file_modification_setxattr

    ## Record Successful Permission Changes ot Files - setxattr
    - audit_rules_successful_file_modification_setxattr

    ## Record Unsuccessul Permission Changes to Files - lsetxattr
    - audit_rules_unsuccessful_file_modification_lsetxattr

    ## Record Successful Permission Changes ot Files - lsetxattr
    - audit_rules_successful_file_modification_lsetxattr

    ## Record Unsuccessul Permission Changes to Files - fsetxattr
    - audit_rules_unsuccessful_file_modification_fsetxattr

    ## Record Successful Permission Changes ot Files - fsetxattr
    - audit_rules_successful_file_modification_fsetxattr

    ## Record Unsuccessul Permission Changes to Files - removexattr
    - audit_rules_unsuccessful_file_modification_removexattr

    ## Record Successful Permission Changes ot Files - removexattr
    - audit_rules_successful_file_modification_removexattr

    ## Record Unsuccessul Permission Changes to Files - lremovexattr
    - audit_rules_unsuccessful_file_modification_lremovexattr

    ## Record Successful Permission Changes ot Files - lremovexattr
    - audit_rules_successful_file_modification_lremovexattr

    ## Record Unsuccessul Permission Changes to Files - fremovexattr
    - audit_rules_unsuccessful_file_modification_fremovexattr

    ## Record Successful Permission Changes ot Files - fremovexattr
    - audit_rules_successful_file_modification_fremovexattr

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Ownership Change
    ##
    #################################################################

    ## Record Unsuccessul Ownership Changes to Files - lchown
    - audit_rules_unsuccessful_file_modification_lchown

    ## Record Successful Ownership Changes to Files - lchown
    - audit_rules_successful_file_modification_lchown

    ## Record Unsuccessul Ownership Changes to Files - fchown
    - audit_rules_unsuccessful_file_modification_fchown

    ## Record Successful Ownership Changes to Files - fchown
    - audit_rules_successful_file_modification_fchown

    ## Record Unsuccessul Ownership Changes to Files - chown
    - audit_rules_unsuccessful_file_modification_chown

    ## Record Successful Ownership Changes to Files - chown
    - audit_rules_successful_file_modification_chown

    ## Record Unsuccessul Ownership Changes to Files - fchownat
    - audit_rules_unsuccessful_file_modification_fchownat

    ## Record Successful Ownership Changes to Files - fchownat
    - audit_rules_successful_file_modification_fchownat

    #################################################################
    ##
    ## Audit User Add, Delete, Modify
    ##
    ## This is covered by PAM. However, someone could open a file
    ## and directly create of modify a user, so we'll watch
    ## passwd and shadow for writes.
    ##
    #################################################################
    ## User add delete modify. This is covered by pam. However, someone could
    ## open a file and directly create or modify a user, so we'll watch passwd and
    ## shadow for writes
    #-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify
    #-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify

    ## Record Events that Modify User/Group Information via openat syscall - /etc/passwd
    - audit_rules_etc_passwd_openat

    ## Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/passwd
    - audit_rules_etc_passwd_open_by_handle_at

    ## Record Events that Modify User/Group Information via open syscall - /etc/passwd
    - audit_rules_etc_passwd_open

    ## Record Events that Modify User/Group Information via openat syscall - /etc/shadow
    - audit_rules_etc_shadow_openat

    ## Record Events that Modify User/Group Information via open_by_handle_at syscall - /etc/shadow
    - audit_rules_etc_shadow_open_by_handle_at

    ## Record Events that Modify User/Group Information via open syscall - /etc/shadow
    - audit_rules_etc_shadow_open

    #################################################################
    ##
    ## Audit User Enable and Disable
    ##
    ## These events are covered by PAM. No special audit rules
    ## are required.
    ##
    #################################################################
    

    #################################################################
    ##
    ## Audit Group Add, Delete, and Modify
    ##
    ## These events are covered by PAM. However, someone could
    ## open a file and directly create or modify a user or group, so
    ## we'll watch the files directly for write activity.
    ##
    #################################################################
    
    ## Record Events that Modify User/Group Information - /etc/group
    - audit_rules_usergroup_modification_group

    ## Record Events that Modify User/Group Information - /etc/gshadow
    - audit_rules_usergroup_modification_gshadow

    ## Record Events that Modify User/Group Information - /etc/passwd
    - audit_rules_usergroup_modification_passwd

    ## Record Events that Modify User/Group Information - /etc/shadow
    - audit_rules_usergroup_modification_shadow

    #################################################################
    ##
    ## Audit Privileged Commands
    ##
    ## Use of special rights for config changes. This would be use
    ## of setuid programs that relate to user accounts. This is not
    ## all setuid apps because requirements are only for the ones
    ## that affect system configuration.
    ##
    #################################################################

    ## Ensure auditd Collects Information on the Use of Privileged Commands - at
    - audit_rules_privileged_commands_at

    ## Ensure auditd Collects Information on the Use of Privileged Commands - crontab
    - audit_rules_privileged_commands_crontab

    ## Ensure auditd Collects Information on the Use of Privileged Commands - gpasswd
    - audit_rules_privileged_commands_gpasswd

    ## Ensure auditd Collects Information on the Use of Privileged Commands - mount
    - audit_rules_privileged_commands_mount

    ## Ensure auditd Collects Information on the Use of Privileged Commands - newgidmap
    - audit_rules_privileged_commands_newgidmap

    ## Ensure auditd Collects Information on the Use of Privileged Commands - newgrp
    - audit_rules_privileged_commands_newgrp

    ## Ensure auditd Collects Information on the Use of Privileged Commands - newuidmap
    - audit_rules_privileged_commands_newuidmap

    ## Ensure auditd Collects Information on the Use of Privileged Commands - passwd
    - audit_rules_privileged_commands_passwd

    ## Record Any Attempts to Run seunshare
    - audit_rules_execution_seunshare

    ## Ensure auditd Collects Information on the Use of Privileged Commands - umount
    - audit_rules_privileged_commands_umount

    ## Ensure auditd Collects Information on the Use of Privileged Commands - unix_chkpwd
    - audit_rules_privileged_commands_unix_chkpwd

    ## Ensure auditd Collects Information on the Use of Privileged Commands - userhelper
    - audit_rules_privileged_commands_userhelper

    ## Ensure auditd Collects Information on the Use of Privileged Commands - usernetctl
    - audit_rules_privileged_commands_usernetctl


    #################################################################
    ##
    ## Audit Attempts to Alter Logging Data
    ##
    #################################################################

    ## Record Access Events to Audit Log Directory
    - directory_access_var_log_audit

    #################################################################
    ##
    ## Audit Loading Kernel Modules
    ##
    #################################################################

    ## Ensure auditd Collects Information on Kernel Module Loading - init_module
    - audit_rules_kernel_module_loading_init

    ## Ensure auditd Collects Information on Kernel Module Loading - finit_module
    - audit_rules_kernel_module_loading_finit

    ## Ensure auditd Collects Information on Kernel Module Unloading - delete_module
    - audit_rules_kernel_module_loading_delete


    #################################################################
    ##
    ## Audit Attempts to Alter Process & Session Ininitiation
    ##
    #################################################################

    ## Record Attempts to Alter Process and Session Initiation Information
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4505
    ##  known bug, need to breakout OVAL into independent checks:
    #   -a always,exit -F path=/var/log/wtmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session
    #   -a always,exit -F path=/var/run/utmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session
    #   -a always,exit -F path=/var/log/btmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session
    - audit_rules_session_events

    #################################################################
    ##
    ## Audit Attempts to Alter MAC Controls
    ##
    #################################################################

    ## Record Events that Modify the System's Mandatory Access Controls
    ##  TO DO: known but about syntax
    ##          https://github.com/ComplianceAsCode/content/issues/4504
    - audit_rules_mac_modification


    #################################################################
    ## Audit Configuration
    #################################################################

    # TODO: local_events=YES

    # TODO: write_logs=YES

    # TODO: log_format=ENRICHED

    ## Configure auditd flush priority
    - auditd_data_retention_flush
    - var_auditd_flush=incremental_async

    # TODO: freq=50

    # TODO: name_format=HOSTNAME


    #################################################################
    ## Audispd plugins
    #################################################################

    ## Configure auditd to use audispd's syslog plugin
    - auditd_audispd_syslog_plugin_activated

    #################################################################
    ## Application Whitelisting
    #################################################################
    - package_fapolicyd_installed
    - service_fapolicyd_enabled

    #################################################################
    ## Harden USB Guard
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4498
    #set -g lock-after-time 900

    ## Configure the tmux Lock Command
    - configure_tmux_lock_command

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4499
    #set -g status off

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
    ## Software update
    #################################################################

    ## Ensure Red Hat GPG Key Installed
    - ensure_redhat_gpgkey_installed

    ## Ensure gpgcheck Enabled In Main yum Configuration
    - ensure_gpgcheck_globally_activated

    ## Ensure gpgcheck Enabled for Local Packages
    - ensure_gpgcheck_local_packages

    ## Ensure gpgcheck Enabled for All yum Package Repositories
    - ensure_gpgcheck_never_disabled


    #################################################################
    ## Kernel Security Settings
    #################################################################

    ## Restrict Exposed Kernel Pointer Addresses Access
    - sysctl_kernel_kptr_restrict

    ## Restrict Access to Kernel Message Buffer
    - sysctl_kernel_dmesg_restrict

    ## Disallow kernel profiling by unprivileged users
    - sysctl_kernel_perf_event_paranoid

    ## Disable Kernel Image Loading
    - sysctl_kernel_kexec_load_disabled

    ## Disable the use of user namespaces
    - sysctl_user_max_user_namespaces

    ## Disable Access to Network bpf() Syscall From Unprivileged Processes
    - sysctl_kernel_unprivileged_bpf_disabled

    ## Harden the operation of the BPF just-in-time compiler
    - sysctl_net_core_bpf_jit_harden

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4495
    #cp -f /usr/lib/sysctl.d/10-default-yama-scope.conf /etc/sysctl.d/

    ## Restrict Usage of ptrace To Descendant Processes
    - sysctl_kernel_yama_ptrace_scope

    #################################################################
    ## Network Settings
    #################################################################

    ## Disable Accepting Router Advertisements on All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_ra

    ## Disable Accepting Router Advertisements on All IPv6 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_ra

    ## Disable Accepting ICMP Redirects for All IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_redirects

    ## Disable Accepting ICMP Redirects for All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_redirects

    ## Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
    - sysctl_net_ipv4_conf_default_accept_redirects

    ## Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces
    - sysctl_net_ipv6_conf_default_accept_redirects

    ## Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_source_route

    ## Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_source_route

    ## Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_accept_source_route

    ## Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_source_route

    ## Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_secure_redirects

    ## Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_secure_redirects

    ## Disable Kernel Parameter for Sending ICMP Redirects on all IPv4  Interfaces 
    - sysctl_net_ipv4_conf_all_send_redirects

    ## Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_send_redirects

    ## Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_log_martians

    ## Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_log_martians

    ## Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_rp_filter

    ## Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_rp_filter

    ## Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    ## Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces
    - sysctl_net_ipv4_icmp_echo_ignore_broadcasts

    ## TO DO: NEED SCAP RULE
    #echo "net.ipv6.icmp.echo_ignore_all = 0" >> $CONFIG

    ## Disable Kernel Parameter for IP Forwarding on IPv4 Interfaces
    - sysctl_net_ipv4_ip_forward

    ## Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces
    - sysctl_net_ipv4_tcp_syncookies

    #################################################################
    ## File System Settings
    #################################################################

    ## Enable Kernel Parameter to Enforce DAC on Hardlinks
    - sysctl_fs_protected_hardlinks

    ## Enable Kernel Parameter to Enforce DAC on Symlinks
    - sysctl_fs_protected_symlinks


    #################################################################
    ## Disable Core Dumps
    #################################################################
    
    ## Disable storing core dumps
    - sysctl_kernel_core_pattern
    #sed -i "/^#Storage/s/#Storage=external/Storage=none/" /etc/systemd/coredump.conf
    #sed -i "/^#ProcessSize/s/#ProcessSizeMax=2G/ProcessSizeMax=0/" /etc/systemd/coredump.conf
    #systemctl mask systemd-coredump.socket
    #systemctl mask kdump.service

    #################################################################
    ## Blacklist Risky Kernel Modules
    #################################################################

    ## Disable IEEE 1394 (FireWire) Support
    - kernel_module_firewire-core_disabled

    ## Disable Mounting of cramfs
    - kernel_module_cramfs_disabled

    ## Disable ATM Support
    - kernel_module_atm_disabled

    ## Disable Bluetooth Kernel Module
    - kernel_module_bluetooth_disabled
    
    ## Disable CAN Support
    - kernel_module_can_disabled

    ## Disable SCTP Support
    - kernel_module_sctp_disabled
    
    ## Disable Transparent Inter Process Communication Support
    - kernel_module_tipc_disabled

    #################################################################
    ## Systemd Items
    #################################################################

    ## Disable Ctrl-Alt-Del Reboot Activation
    - disable_ctrlaltdel_reboot

    ## Disable Ctrl-Alt-Del Burst Action
    - disable_ctrlaltdel_burstaction

    ## Disable debug-shell SystemD Service
    - service_debug-shell_disabled

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4460
    # sed -i "/^#SystemMaxUse/s/#SystemMaxUse=/SystemMaxUse=200/" /etc/systemd/journald.conf

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4461
    # systemctl mask systemd-resolved.service

    #################################################################
    ## Configure Hostname
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4462
    ## echo "ospp" > /etc/hostname
    ## sed -i "s/localhost\.localdomain/ospp/g" /etc/hosts

    #################################################################
    ## Audit Daemon Configuration
    #################################################################

    #chmod -R 640 "$RULES/*"

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4463
    #sed -i "/name_format/s/NONE/HOSTNAME/" /etc/audit/auditd.conf

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4464
    #sed -i "/^active/s/no/yes/" /etc/audit/plugins.d/syslog.conf

    ## Point rsyslog to a remote system to collect logs. This will need
    ## remote_host and port corrected on the Target line.
    #CONFIG="/etc/rsyslog.conf"
    #sed -i "/#action/s/^#//" $CONFIG
    #sed -i "/#queue/s/^#//" $CONFIG
    #sed -i "/#Target/s/^#//" $CONFIG

    #################################################################
    ## Firewall & Network Manager
    #################################################################

    - service_firewalld_enabled

    #################################################################
    ## Harden chrony (time server)
    #################################################################

    ## Disable chrony daemon from acting as server
    - chronyd_client_only

    ## Disable network management of chrony daemon
    - chronyd_no_chronyc_network

    #################################################################
    ## Setup SSH Server
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4466
    #sed -i "/ed25519/s/HostKey/#HostKey/" $CONFIG

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4467
    #sed -i "s/#RekeyLimit default none/RekeyLimit 512M/" $CONFIG

    ## Disable SSH Root Login
    - sshd_disable_root_login

    ## Enable Use of Strict Mode Checking
    - sshd_enable_strictmodes

    ## Disable Host-Based Authentication
    - disable_host_auth

    ## Disable SSH Support for User Known Hosts
    - sshd_disable_user_known_hosts

    ## Disable SSH Support for .rhosts Files
    - sshd_disable_rhosts

    ## Disable SSH Access via Empty Passwords
    - sshd_disable_empty_passwords

    ## Disable Kerberos Authentication
    - sshd_disable_kerb_auth

    ## Disable GSSAPI Authentication
    - sshd_disable_gssapi_auth

    ## Set SSH Idle Timeout Interval
    - sshd_idle_timeout_value=10_minutes
    - sshd_set_idle_timeout

    ## Set SSH Client Alive Max Count
    - var_sshd_set_keepalive=3
    - sshd_set_keepalive

    ## Enable SSH Warning Banner
    - sshd_enable_warning_banner

    ## Use Only FIPS 140-2 Validated Ciphers
    - sshd_use_approved_ciphers

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4469
    #echo -e "PubkeyAcceptedKeyTypes ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384" >> $CONFIG

    ## Use Only FIPS 140-2 Validated MACs
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4470
    - sshd_use_approved_macs

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4471
    #echo -e "KexAlgorithms diffie-hellman-group14-sha1,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521" >> $CONFIG

    #################################################################
    ## Enable rngd Service
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4472
    #sysctl enable rngd.service

    #################################################################
    ## sssd Settings
    #################################################################
    ## TO DO -- entire section

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4501
    ## sssd settings
    ## FIXME: We need to point this to a remote LDAP policy server
    #CONFIG="/etc/sssd/conf.d/ospp.conf"
    #touch $CONFIG
    #chmod 600 $CONFIG
    #echo -e "[sssd]" >> $CONFIG
    #echo -e "user = sssd\n" >> $CONFIG

    ## Configure SSSD to run as user sssd
    - sssd_run_as_sssd_user

    #################################################################
    ## Enable / Configure USB Guard
    #################################################################
    
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4473
    #sed -i "/AuditBackend/s/FileAudit/LinuxAudit/" /etc/usbguard/usbguard-daemon.conf

    ## TO DO: HOW TO HANDLE??
    #setup_usbguard

    ## Enable the USBGuard Service
    - service_usbguard_enabled

    #################################################################
    ## Enable / Configure FIPS
    #################################################################
    
    ## Enable FIPS Mode
    - enable_fips_mode

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4500
    # - sysctl_crypto_fips_enabled

    ## Enable Dracut FIPS Module
    - enable_dracut_fips_module

    # - etc_system_fips_exists

    #################################################################
    ## Libreswan Setup
    #################################################################
    
    ## libreswan setup
    # FIXME: Need to talk to Paul about generic server/client setups
    # And for servers, need to punch holes in firewall

    #################################################################
    ## Account & Password Settings
    #################################################################

    ## Set Password Minimum Length in login.defs
    - var_accounts_password_minlen_login_defs=12
    - accounts_password_minlen_login_defs

    ## Ensure PAM Enforces Password Requirements - Minimum Different Characters
    - var_password_pam_difok=4
    - accounts_password_pam_difok

    ## Ensure PAM Enforces Password Requirements - Minimum Length
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen

    ## Minimum Digit Characters
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ## Ensure PAM Enforces Password Requirements - Minimum Uppercase Characters
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ## Ensure PAM Enforces Password Requirements - Minimum Lowercase Characters
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ## Ensure PAM Enforces Password Requirements - Minimum Special Characters
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ## Set Password Maximum Consecutive Repeating Characters
    - var_password_pam_maxrepeat=3
    - accounts_password_pam_maxrepeat

    ## Ensure PAM Enforces Password Requirements - Maximum Consecutive Repeating Characters from Same Character Class
    - var_password_pam_maxclassrepeat=4
    - accounts_password_pam_maxclassrepeat

    ## Set umask Variable for next few rules
    - var_accounts_user_umask=027

    ## Ensure the Default Umask is Set Correctly in /etc/profile
    - accounts_umask_etc_profile

    ## Ensure the Default Bash Umask is Set Correctly
    - accounts_umask_etc_bashrc

    ## Ensure the Default C Shell Umask is Set Correctly
    - accounts_umask_etc_csh_cshrc

    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4475
    # - accounts_umask_etc_login_defs

    #################################################################
    ## PAM Setup
    #################################################################

    ## Disable Core Dumps for All Users
    - disable_users_coredumps

    ## Limit the Number of Concurrent Login Sessions Allowed Per User
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions

    ## RANDOM TO DO
    #sed -i "6s/^#//" /etc/pam.d/su
    #sed -i "8iauth        required      pam_faillock.so preauth silent " /etc/pam.d/system-auth
    #sed -i "8iauth        required      pam_faillock.so preauth silent " /etc/pam.d/password-auth

    # securetty is disabled by default in RHEL8, but it can be enabled just by editing a few files
    - securetty_root_login_console_only

    ## Limit Password Reuse
    - accounts_password_pam_unix_remember
    - var_password_pam_unix_remember=5

    ## Set Deny For Failed Password Attempts
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny

    ## Set Interval For Counting Failed Password Attempts
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval

    ## Set Lockout Time for Failed Password Attempts
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time


    ## Prevent Login to Accounts With Empty Password
    - no_empty_passwords

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4480
    #sed -i 's/nullok//' /etc/pam.d/system-auth

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4481
    #sed -i 's/nullok//' /etc/pam.d/sssd-shadowutils

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4479
    ## setup tmux
    #mv /tmp/tmux.conf /etc/tmux.conf
    #restorecon /etc/tmux.conf
    #sed -i 's/^fi/  if [ "$PS1" ]; then\n    [[ $TERM != "screen" ]] \&\& exec tmux\n  fi\nfi/' /etc/bashrc
    #sed -i '/tmux$/d' /etc/shells

    #################################################################
    ## Enable Automatic Software Updates
    #################################################################

    ## RHEL 8 CCE-82267-6: Configure dnf-automatic to Install Only Security Updates
    - dnf-automatic_security_updates_only

    ## Configure dnf-automatic to Install Available Updates Automatically
    - dnf-automatic_apply_updates

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4478
    #systemctl enable --now dnf-automatic.timer
