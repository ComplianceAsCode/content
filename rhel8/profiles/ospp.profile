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

    ## RHEL 8 CCE-80869-1: Ensure SELinux is Enforcing
    - var_selinux_state=enforcing
    - selinux_state

    ## RHEL 8 CCE-80868-3: Configure SELinux Policy
    - var_selinux_policy_name=targeted
    - selinux_policytype


    #################################################################
    ## Bootloader Configuration
    #################################################################
    #TO DO: bootloader --location=mbr --append="boot=/dev/vda1 fips=1 "

    ## RHEL 8 CCE-80829-5: Set the UEFI Boot Loader Password
    - grub2_uefi_password

    ## RHEL 8 CCE-80855-0: Require Authentication for Single User Mode
    - require_singleuser_auth

    ## RHEL 8 CCE-80826-1: Verify that Interactive Boot is Disabled
    - grub2_disable_interactive_boot

    ## RHEL 8 CCE-80825-3: Enable Auditing for Processes Which Start Prior to the Audit Daemon
    - grub2_audit_argument

    ## RHEL 8 CCE-80943-4: Extend Audit Backlog Limit for the Audit Daemon
    - grub2_audit_backlog_limit_argument

    ## RHEL 8 CCE-80945-9: Enable SLUB/SLAB allocator poisoning
    - grub2_slub_debug_argument

    ## RHEL 8 CCE-80944-2: Enable page allocator poisoning
    - grub2_page_poison_argument

    ## Enable Kernel Page-Table Isolation (KPTI)
    - grub2_pti_argument

    ## RHEL 8 CCE-80946-7: Disable vsyscalls
    - grub2_vsyscall_argument


    #################################################################
    ## Partitioning Configuration
    #################################################################

    ###########
    ## /boot
    ###########
    # TO DO: /boot on its own partition?!

    ## RHEL 8 CCE-82941-6: Add nodev Option to /boot
    - mount_option_boot_nodev

    ## RHEL 8 CCE-81033-3: Add nosuid Option to /boot
    - mount_option_boot_nosuid

    ###########
    ## /home
    ###########

    ## RHEL 8 CCE-81044-0: Ensure /home Located On Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4484
    ##  unclear if partition requirements still relevant
    - partition_for_home

    ## RHEL 8 CCE-81048-1: Add nodev Option to /home
    - mount_option_home_nodev

    ## RHEL 8 CCE-81050-7: Add nosuid Option to /home
    - mount_option_home_nosuid

    ###########
    ## /var
    ###########

    ## RHEL 8 CCE-80852-7: Ensure /var Located on Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4486
    ##  unclear if partition requirements still exist
    - partition_for_var

    ## RHEL 8 CCE-82062-1: Add nodev Option to /var
    - mount_option_var_nodev

    ###########
    ## /var/log
    ###########

    ## RHEL 8 CCE-80853-5: Ensure /var/log Located on Separate Partition
    - partition_for_var_log

    ## RHEL 8 CCE-82077-9: Add nodev Option to /var/log
    - mount_option_var_log_nodev

    ## RHEL 8 CCE-82065-4: Add nosuid Option to /var/log
    - mount_option_var_log_nosuid

    ## RHEL 8 CCE-82008-4: Add noexec Option to /var/log
    - mount_option_var_log_noexec

    ###########
    ## /var/log/audit
    ###########
    ## RHEL 8 CCE-80854-3: Ensure /var/log/audit Located on Separate Partition
    - partition_for_var_log_audit

    ## RHEL 8 CCE-82080-3: Add nodev Option to /var/log/audit
    - mount_option_var_log_audit_nodev

    ## RHEL 8 CCE-82921-8: Add nosuid Option to /var/log/audit
    - mount_option_var_log_audit_nosuid

    ## RHEL 8 CCE-82975-4: Add noexec Option to /var/log/audit
    - mount_option_var_log_audit_noexec

    ###########
    ## /var/tmp
    ###########

    ## RHEL 8 CCE-81053-1: Add nodev Option to /var/tmp
    - mount_option_var_tmp_nodev

    ## RHEL 8 CCE-82154-6: Add nosuid Option to /var/tmp
    - mount_option_var_tmp_nosuid

    ## RHEL 8 CCE-82151-2: Add noexec Option to /var/tmp
    - mount_option_var_tmp_noexec

    ###########
    ## /tmp
    ###########

    ## Setup a couple mountpoints by hand to ensure correctness
    #touch /etc/fstab
    ## CCE-26435-8: Ensure /tmp Located On Separate Partition
    #echo -e "tmpfs\t/tmp\t\t\t\ttmpfs\tdefaults,mode=1777,,,nodev,strictatime,size=512M\t0 0" >> /etc/fstab

    ## RHEL 8 CCE-82623-0: Add nodev Option to /tmp
    - mount_option_tmp_nodev

    ## RHEL 8 CCE-82139-7: Add noexec Option to /tmp
    - mount_option_tmp_noexec

    ## RHEL 8 CCE-82140-5: Add nosuid Option to /tmp
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

    ## RHEL 8 CCE-80837-8: Add nodev Option to /dev/shm
    - mount_option_dev_shm_nodev

    ## RHEL 8 CCE-80838-6: Add noexec Option to /dev/shm
    - mount_option_dev_shm_noexec

    ## RHEL 8 CCE-80839-4: Add nosuid Option to /dev/shm
    - mount_option_dev_shm_nosuid

    ###########
    ## Misc Partitioning
    ###########
    ## RHEL 8 CCE-81054-9: Add nodev Option to Non-Root Local Partitions
    - mount_option_nodev_nonroot_local_partitions

    #################################################################
    ## Required Packages
    #################################################################

    ## RHEL 8 CCE-82995-2: Install cryptsetup-luks Package
    - package_cryptsetup-luks_installed

    ## RHEL 8 CCE-82994-5: Install sssd-ipa Package
    - package_sssd-ipa_installed

    ## RHEL 8 CCE-80844-4: Install aide Package
    - package_aide_installed

    ## RHEL 8 CCE-82989-5: Install binutils Package
    - package_binutils_installed

    ## RHEL 8 CCE-82985-3: Install dnf-automatic Package
    - package_dnf-automatic_installed

    ## RHEL 8 CCE-82998-6: Install firewalld Package
    - package_firewalld_installed

    ## RHEL 8 CCE-82982-0: Install iptables Package
    - package_iptables_installed

    ## RHEL 8 CCE-82979-6: Install libcap-ng-utils Package
    - package_libcap-ng-utils_installed

    ## RHEL 8 CCE-82976-2: Install openscap-scanner Package
    - package_openscap-scanner_installed

    ## RHEL 8 CCE-82976-2: Install policycoreutils Package
    - package_policycoreutils_installed

    ## RHEL 8 CCE-82973-9: Install python-rhsm Package
    - package_python-rhsm_installed

    ## RHEL 8 CCE-82968-9: Install rng-tools Package
    - package_rng-tools_installed

    ## RHEL 8 CCE-82965-5: Install sudo Package
    - package_sudo_installed

    ## RHEL 8 CCE-82965-5: Install tar Package
    - package_tar_installed

    ## RHEL 8 CCE-80644-8: Install tmux Package
    - package_tmux_installed

    ## RHEL 8 CCE-82959-8: Install usbguard Package
    - package_usbguard_installed

    ## RHEL 8 CCE-82956-4: Install vim Package
    - package_vim_installed

    ### RHEL 8 CCE-82953-1: Install audispd-plugins Package
    - package_audispd-plugins_installed

    ## RHEL 8 CCE-82949-9: Install scap-security-guide Package
    - package_scap-security-guide_installed

    ## RHEL 8 CCE-81043-2: Ensure the audit Subsystem is Installed
    - package_auditd_installed

    ## RHEL 8 CCE-80845-1: Install libreswan Package
    - package_libreswan_installed

    ## RHEL 8 CCE-80847-7: Ensure rsyslog is Installed
    - package_rsyslog_installed

    #################################################################
    ## Remove Prohibited Packages
    #################################################################

    ## RHEL 8 CCE-81039-0: Uninstall Sendmail Package
    - package_sendmail_removed

    ## RHEL 8 CCE-82946-5: Uninstall iprutils Package
    - package_iprutils_removed

    ## RHEL 8 CCE-82943-2: Uninstall gssproxy Package
    - package_gssproxy_removed

    ## RHEL 8 CCE-82939-0: Uninstall geolite2-city Package
    - package_geolite2-city_removed

    ## RHEL 8 CCE-82936-6: Uninstall geolite2-country Package
    - package_geolite2-country_removed

    ## RHEL 8 CCE-82932-5: Uninstall nfs-utils Package
    - package_nfs-utils_removed

    ## RHEL 8 CCE-82931-7: Uninstall krb5-workstation Package
    - package_krb5-workstation_removed

    ## RHEL 8 CCE-82926-7: Uninstall abrt-addon-kerneloops Package
    - package_abrt-addon-kerneloops_removed

    ## RHEL 8 CCE-82923-4: Uninstall abrt-addon-python Package
    - package_abrt-addon-python_removed

    ## RHEL 8 CCE-82919-2: Uninstall abrt-addon-ccpp Package
    - package_abrt-addon-ccpp_removed

    ## RHEL 8 CCE-82916-8: Uninstall abrt-plugin-rhtsupport Package
    - package_abrt-plugin-rhtsupport_removed

    ## RHEL 8 CCE-82946-5: Uninstall abrt-plugin-logger Package
    - package_abrt-plugin-logger_removed

    ## RHEL 8 CCE-82910-1: Uninstall abrt-plugin-sosreport Package
    - package_abrt-plugin-sosreport_removed

    ## RHEL 8 CCE-82907-7: Uninstall abrt-cli Package
    - package_abrt-cli_removed

    ## RHEL 8 CCE-82904-4: Uninstall tuned Package
    - package_tuned_removed

    ## RHEL 8 CCE-80948-3: Uninstall Automatic Bug Reporting Tool (abrt)
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

    ## RHEL 8 CCE-80872-5: Enable auditd Service
    - service_auditd_enabled


    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Creation
    ## (open with O_CREAT)
    ##
    #################################################################

    ## RHEL 8 CCE-80962-4: Record Unsuccessful Creation Attempts to Files - openat O_CREAT
    - audit_rules_unsuccessful_file_modification_openat_o_creat

    ## RHEL 8 CCE-81128-1: Record Successful Creation Attempts to Files - opanat O_CREAT
    - audit_rules_successful_file_modification_openat_o_creat

    ## RHEL 8 CCE-80965-7: Record Unsuccessful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat

    ## RHEL 8 CCE-81132-3: Record Successful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_successful_file_modification_open_by_handle_at_o_creat

    ## RHEL 8 CCE-80968-1: Record Unsuccessful Creation Attempts to Files - open O_CREAT
    - audit_rules_unsuccessful_file_modification_open_o_creat

    ## RHEL 8 CCE-81135-6: Record Successful Creation Attempts to Files - open O_CREAT
    - audit_rules_successful_file_modification_open_o_creat

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Modifications
    ## (open for write or truncate with O_TRUNC_WRITE)
    ##
    #################################################################

    ## RHEL 8 CCE-80963-2: Record Unsuccessful Modification Attempts to Files - openat O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write

    ## RHEL 8 CCE-81138-0: Record Successful Modification Attempts to Files - openat O_TRUNC_WRITE
    - audit_rules_successful_file_modification_openat_o_trunc_write

    ## RHEL 8 CCE-80966-5: Record Unsuccessful Modification Attempts to Files - open_by_handle_at O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write

    ## RHEL 8 CCE-81141-4: Record Successful Modification Attempts to Files - open_by_handle_at O_TRUNC_WRITE
    - audit_rules_successful_file_modification_open_by_handle_at_o_trunc_write

    ## RHEL 8 CCE-80969-9: Record Unsuccessful Modification Attempts to Files - open O_TRUNC_WRITE
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write

    ## RHEL 8 CCE-81144-8: Record Successful Modification Attempts to Files - open O_TRUNC_WRITE
    - audit_rules_successful_file_modification_open_o_trunc_write

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Access
    ## (any other opens)
    ##
    ## This has to go last.
    ##
    #################################################################

    ## RHEL 8 CCE-80753-7: Record Unsuccessful Access Attempts to Files - open
    - audit_rules_unsuccessful_file_modification_open

    ## RHEL 8 CCE-81147-1: Record Successful Access Attempts to Files - open
    - audit_rules_successful_file_modification_open

    ## RHEL 8 CCE-80751-1: Record Unsuccessful Access Attempts to Files - creat
    - audit_rules_unsuccessful_file_modification_creat

    ## RHEL 8 CCE-81150-5: Record Successful Access Attempts to Files - creat
    - audit_rules_successful_file_modification_creat

    ## RHEL 8 CCE-80756-0: Record Unsuccessful Access Attempts to Files - truncate
    - audit_rules_unsuccessful_file_modification_truncate

    ## RHEL 8 CCE-82002-7: Record Successful Access Attempts to Files - truncate
    - audit_rules_successful_file_modification_truncate

    ## RHEL 8 CCE-80752-9: Record Unsuccessful Access Attempts to Files - ftruncate
    - audit_rules_unsuccessful_file_modification_ftruncate

    ## RHEL 8 CCE-82006-8: Record Successful Access Attempts to Files - ftruncate
    - audit_rules_successful_file_modification_ftruncate

    ## RHEL 8 CCE-80754-5: Record Unsuccessful Access Attempts to Files - openat
    - audit_rules_unsuccessful_file_modification_openat

    ## RHEL 8 CCE-82010-0: Record Successful Access Attempts to Files - openat
    - audit_rules_successful_file_modification_openat

    ## RHEL 8 CCE-80755-2: Record Unsuccessful Access Attempts to Files - open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ## RHEL 8 CCE-82013-4: Record Successful Access Attempts to Files - open_by_handle_at
    - audit_rules_successful_file_modification_open_by_handle_at

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Delete
    ##
    #################################################################

    ## RHEL 8 CCE-80971-5: Record Unsuccessful Delete Attempts to Files - unlink
    - audit_rules_unsuccessful_file_modification_unlink

    ## TO DO: Record Successful Delete Attempts to Files - unlink
    - audit_rules_successful_file_modification_unlink

    ## RHEL 8 CCE-80972-3: Record Unsuccessful Delete Attempts to Files - unlinkat
    - audit_rules_unsuccessful_file_modification_unlinkat

    ## TO DO: Record Successful Delete Attempts to Files - unlinkat
    - audit_rules_successful_file_modification_unlinkat

    ## RHEL 8 CCE-80973-1: Record Unsuccessful Delete Attempts to Files - rename
    - audit_rules_unsuccessful_file_modification_rename

    ## TO DO: Record Successful Delete Attempts to Files - rename
    - audit_rules_successful_file_modification_rename

    ## RHEL 8 CCE-80974-9: Record Unsuccessful Delete Attempts to Files - renameat
    - audit_rules_unsuccessful_file_modification_renameat

    ## TO DO: Record Successful Delete Attempts to Files - renameat
    - audit_rules_successful_file_modification_renameat

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Permission Change
    ##
    #################################################################

    ## RHEL 8 CCE-80975-6: Record Unsuccessul Permission Changes to Files - chmod
    - audit_rules_unsuccessful_file_modification_chmod

    ## RHEL 8 CCE:82098-5: Record Successful Permission Changes to Files - chmod
    - audit_rules_successful_file_modification_chmod

    ## RHEL 8 CCE-80977-2: Record Unsuccessul Permission Changes to Files - fchmod
    - audit_rules_unsuccessful_file_modification_fchmod

    ## RHEL 8 CCE-82101-7: Record Successful Permission Changes to Files - fchmod
    - audit_rules_successful_file_modification_fchmod

    ## RHEL 8 CCE-80976-4: Record Unsuccessul Permission Changes to Files - fchmodat
    - audit_rules_unsuccessful_file_modification_fchmodat

    ## RHEL 8 CCE-82104-1: Record Successful Permission Changes ot Files - fchmodat
    - audit_rules_successful_file_modification_fchmodat

    ## RHEL 8 CCE-80983-0: Record Unsuccessul Permission Changes to Files - setxattr
    - audit_rules_unsuccessful_file_modification_setxattr

    ## RHEL 8 CCE-82107-4: Record Successful Permission Changes ot Files - setxattr
    - audit_rules_successful_file_modification_setxattr

    ## RHEL 8 CCE-80981-4: Record Unsuccessul Permission Changes to Files - lsetxattr
    - audit_rules_unsuccessful_file_modification_lsetxattr

    ## RHEL 8 CCE-82110-8: Record Successful Permission Changes ot Files - lsetxattr
    - audit_rules_successful_file_modification_lsetxattr

    ## RHEL 8 CCE-80979-8: Record Unsuccessul Permission Changes to Files - fsetxattr
    - audit_rules_unsuccessful_file_modification_fsetxattr

    ## RHEL 8 CCE-82113-2: Record Successful Permission Changes ot Files - fsetxattr
    - audit_rules_successful_file_modification_fsetxattr

    ## RHEL 8 CCE-80982-2: Record Unsuccessul Permission Changes to Files - removexattr
    - audit_rules_unsuccessful_file_modification_removexattr

    ## RHEL 8 CCE-82116-5: Record Successful Permission Changes ot Files - removexattr
    - audit_rules_successful_file_modification_removexattr

    ## RHEL 8 CCE-80980-6: Record Unsuccessul Permission Changes to Files - lremovexattr
    - audit_rules_unsuccessful_file_modification_lremovexattr

    ## RHEL 8 CCE-82119-9: Record Successful Permission Changes ot Files - lremovexattr
    - audit_rules_successful_file_modification_lremovexattr

    ## RHEL 8 CCE-80978-0: Record Unsuccessul Permission Changes to Files - fremovexattr
    - audit_rules_unsuccessful_file_modification_fremovexattr

    ## RHEL 8 CCE-82122-3: Record Successful Permission Changes ot Files - fremovexattr
    - audit_rules_successful_file_modification_fremovexattr

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Ownership Change
    ##
    #################################################################

    ## RHEL 8 CCE-80987-1: Record Unsuccessul Ownership Changes to Files - lchown
    - audit_rules_unsuccessful_file_modification_lchown

    ## RHEL 8 CCE-32125-6: Record Successful Ownership Changes to Files - lchown
    - audit_rules_successful_file_modification_lchown

    ## RHEL 8 CCE-80986-3: Record Unsuccessul Ownership Changes to Files - fchown
    - audit_rules_unsuccessful_file_modification_fchown

    ## RHEL 8 CCE-82128-0: Record Successful Ownership Changes to Files - fchown
    - audit_rules_successful_file_modification_fchown

    ## RHEL 8 CCE-80984-8: Record Unsuccessul Ownership Changes to Files - chown
    - audit_rules_unsuccessful_file_modification_chown

    ## RHEL 8 CCE-82131-4: Record Successful Ownership Changes to Files - chown
    - audit_rules_successful_file_modification_chown

    ## RHEL 8 CCE-80985-5: Record Unsuccessul Ownership Changes to Files - fchownat
    - audit_rules_unsuccessful_file_modification_fchownat

    ## RHEL 8 CCE-82134-8: Record Successful Ownership Changes to Files - fchownat
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
    
    ## RHEL 8 CCE-80758-6: Record Events that Modify User/Group Information - /etc/group
    - audit_rules_usergroup_modification_group

    ## RHEL 8 CCE-80759-4: Record Events that Modify User/Group Information - /etc/gshadow
    - audit_rules_usergroup_modification_gshadow

    ## RHEL 8 CCE-80761-0: Record Events that Modify User/Group Information - /etc/passwd
    - audit_rules_usergroup_modification_passwd

    ## RHEL 8 CCE-80762-8: Record Events that Modify User/Group Information - /etc/shadow
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

    ## RHEL 8 CCE-80988-9: Ensure auditd Collects Information on the Use of Privileged Commands - at
    - audit_rules_privileged_commands_at

    ## RHEL 8 CCE-80727-1: Ensure auditd Collects Information on the Use of Privileged Commands - crontab
    - audit_rules_privileged_commands_crontab

    ## RHEL 8 CCE-80728-9: Ensure auditd Collects Information on the Use of Privileged Commands - gpasswd
    - audit_rules_privileged_commands_gpasswd

    ## RHEL 8 CCE-80989-7: Ensure auditd Collects Information on the Use of Privileged Commands - mount
    - audit_rules_privileged_commands_mount

    ## RHEL 8 CCE-80991-3: Ensure auditd Collects Information on the Use of Privileged Commands - newgidmap
    - audit_rules_privileged_commands_newgidmap

    ## RHEL 8 CCE-80729-7: Ensure auditd Collects Information on the Use of Privileged Commands - newgrp
    - audit_rules_privileged_commands_newgrp

    ## RHEL 8 CCE-80992-1: Ensure auditd Collects Information on the Use of Privileged Commands - newuidmap
    - audit_rules_privileged_commands_newuidmap

    ## RHEL 8 CCE-80731-3: Ensure auditd Collects Information on the Use of Privileged Commands - passwd
    - audit_rules_privileged_commands_passwd

    ## RHEL 8 CCE-80933-5: Record Any Attempts to Run seunshare
    - audit_rules_execution_seunshare

    ## RHEL 8 CCE-80739-6: Ensure auditd Collects Information on the Use of Privileged Commands - umount
    - audit_rules_privileged_commands_umount

    ## RHEL 8 CCE-80740-4: Ensure auditd Collects Information on the Use of Privileged Commands - unix_chkpwd
    - audit_rules_privileged_commands_unix_chkpwd

    ## RHEL 8 CCE-80741-2: Ensure auditd Collects Information on the Use of Privileged Commands - userhelper
    - audit_rules_privileged_commands_userhelper

    ## RHEL 8 CCE-80990-5: Ensure auditd Collects Information on the Use of Privileged Commands - usernetctl
    - audit_rules_privileged_commands_usernetctl


    #################################################################
    ##
    ## Audit Attempts to Alter Logging Data
    ##
    #################################################################

    ## RHEL 8 CCE-80941-8: Record Access Events to Audit Log Directory
    - directory_access_var_log_audit

    #################################################################
    ##
    ## Audit Loading Kernel Modules
    ##
    #################################################################

    ## RHEL 8 CCE-80713-1: Ensure auditd Collects Information on Kernel Module Loading - init_module
    - audit_rules_kernel_module_loading_init

    ## RHEL 8 CCE-80712-3: Ensure auditd Collects Information on Kernel Module Loading - finit_module
    - audit_rules_kernel_module_loading_finit

    ## RHEL 8 CCE-80711-5: Ensure auditd Collects Information on Kernel Module Unloading - delete_module
    - audit_rules_kernel_module_loading_delete


    #################################################################
    ##
    ## Audit Attempts to Alter Process & Session Ininitiation
    ##
    #################################################################

    ## RHEL 8 CCE-80742-0: Record Attempts to Alter Process and Session Initiation Information
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

    ## RHEL 8 CCE-80721-4: Record Events that Modify the System's Mandatory Access Controls
    ##  TO DO: known but about syntax
    ##          https://github.com/ComplianceAsCode/content/issues/4504
    - audit_rules_mac_modification


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
    ## Harden USB Guard
    #################################################################

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4498
    #set -g lock-after-time 900

    ## RHEL 8 CCE-80940-0: Configure the tmux Lock Command
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

    ## RHEL 8 CCE-80795-8: Ensure Red Hat GPG Key Installed
    - ensure_redhat_gpgkey_installed

    ## RHEL 8 CCE-80790-9: Ensure gpgcheck Enabled In Main yum Configuration
    - ensure_gpgcheck_globally_activated

    ## RHEL 8 CCE-80791-7: Ensure gpgcheck Enabled for Local Packages
    - ensure_gpgcheck_local_packages

    ## RHEL 8 CCE-80792-5: Ensure gpgcheck Enabled for All yum Package Repositories
    - ensure_gpgcheck_never_disabled


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

    ## Disable the use of user namespaces
    - sysctl_user_max_user_namespaces

    ## RHEL 8 CCE-82203-1: Disable Access to Network bpf() Syscall From Unprivileged Processes
    - sysctl_kernel_unprivileged_bpf_disabled

    ## RHEL 8 CCE-82934-1: Harden the operation of the BPF just-in-time compiler
    - sysctl_net_core_bpf_jit_harden

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4495
    #cp -f /usr/lib/sysctl.d/10-default-yama-scope.conf /etc/sysctl.d/

    ## RHEL 8 CCE-80953-3: Restrict Usage of ptrace To Descendant Processes
    - sysctl_kernel_yama_ptrace_scope

    #################################################################
    ## Network Settings
    #################################################################

    ## RHEL 8 CCE-81006-9: Disable Accepting Router Advertisements on All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_ra

    ## RHEL 8 CCE-81007-7: Disable Accepting Router Advertisements on All IPv6 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_ra

    ## RHEL 8 CCE-80917-8: Disable Accepting ICMP Redirects for All IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_redirects

    ## RHEL 8 CCE-81009-3: Disable Accepting ICMP Redirects for All IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_redirects

    ## RHEL 8 CCE-80919-4: Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
    - sysctl_net_ipv4_conf_default_accept_redirects

    ## RHEL 8 CCE-81010-1: Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces
    - sysctl_net_ipv6_conf_default_accept_redirects

    ## RHEL 8 CCE-81011-9: Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
    - sysctl_net_ipv4_conf_all_accept_source_route

    ## RHEL 8 CCE-81013-5: Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces
    - sysctl_net_ipv6_conf_all_accept_source_route

    ## RHEL 8 CCE-80920-2: Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv4_conf_default_accept_source_route

    ## RHEL 8 CCE-81015-0: Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
    - sysctl_net_ipv6_conf_default_accept_source_route

    ## RHEL 8 CCE-81016-8: Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
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

    ## TO DO: NEED SCAP RULE
    #echo "net.ipv6.icmp.echo_ignore_all = 0" >> $CONFIG

    ## RHEL 8 CCE-81024-2: Disable Kernel Parameter for IP Forwarding on IPv4 Interfaces
    - sysctl_net_ipv4_ip_forward

    ## RHEL 8 CCE-80923-6: Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces
    - sysctl_net_ipv4_tcp_syncookies

    #################################################################
    ## File System Settings
    #################################################################

    ## RHEL 8 CCE-81027-5: Enable Kernel Parameter to Enforce DAC on Hardlinks
    - sysctl_fs_protected_hardlinks

    ## RHEL 8 CCE-81030-9: Enable Kernel Parameter to Enforce DAC on Symlinks
    - sysctl_fs_protected_symlinks


    #################################################################
    ## Disable Core Dumps
    #################################################################
    
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4502
    #echo "kernel.core_pattern=|/bin/false" >> $CONFIG
    #sed -i "/^#Storage/s/#Storage=external/Storage=none/" /etc/systemd/coredump.conf
    #sed -i "/^#ProcessSize/s/#ProcessSizeMax=2G/ProcessSizeMax=0/" /etc/systemd/coredump.conf
    #systemctl mask systemd-coredump.socket
    #systemctl mask kdump.service

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
    ## Systemd Items
    #################################################################

    ## RHEL 8 CCE-80785-9: Disable Ctrl-Alt-Del Reboot Activation
    - disable_ctrlaltdel_reboot

    ## RHEL 8 CCE-80784-2: Disable Ctrl-Alt-Del Burst Action
    - disable_ctrlaltdel_burstaction

    ## RHEL 8 CCE-80876-6: Disable debug-shell SystemD Service
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

    ## RHEL 8 CCE-80877-4
    - service_firewalld_enabled

    #################################################################
    ## Harden chrony (time server)
    #################################################################

    ## RHEL 8 CCE-82988-7: Disable chrony daemon from acting as server
    - chronyd_client_only

    ## RHEL 8 CCE-82840-0: Disable network management of chrony daemon
    - chronyd_no_chronyc_network

    #################################################################
    ## Setup SSH Server
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
    - var_sshd_set_keepalive=3
    - sshd_set_keepalive

    ## TO DO --
    #echo -e "\nReplace this with your organization-defined system use notification message or banner\n" > /etc/issue
    #cp /etc/issue /etc/issue.net
    #sed -i "s/#Banner none/Banner \/etc\/issue.net/" $CONFIG

    ## RHEL 8 CCE-81032-5: Use Only FIPS 140-2 Validated Ciphers
    - sshd_use_approved_ciphers

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4469
    #echo -e "PubkeyAcceptedKeyTypes ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384" >> $CONFIG

    ## RHEL 8 CCE-81034-1: Use Only FIPS 140-2 Validated MACs
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

    ## RHEL 8 CCE-81062-2: Configure SSSD to run as user sssd
    - sssd_run_as_sssd_user

    #################################################################
    ## Enable / Configure USB Guard
    #################################################################
    
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4473
    #sed -i "/AuditBackend/s/FileAudit/LinuxAudit/" /etc/usbguard/usbguard-daemon.conf

    ## TO DO: HOW TO HANDLE??
    #setup_usbguard

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4474
    #systemctl enable usbguard

    #################################################################
    ## Enable / Configure FIPS
    #################################################################
    
    ## RHEL 8 CCE-80942-6: Enable FIPS Mode
    - enable_fips_mode

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4500
    # - sysctl_crypto_fips_enabled

    ## RHEL 8 CCE-82155-3: Enable Dracut FIPS Module
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

    ## RHEL 8 CCE-80652-1: Set Password Minimum Length in login.defs
    - var_accounts_password_minlen_login_defs=12
    - accounts_password_minlen_login_defs

    ## RHEL 8 CCE-80654-7: Ensure PAM Enforces Password Requirements - Minimum Different Characters
    - var_password_pam_difok=4
    - accounts_password_pam_difok

    ## RHEL 8 CCE-80656-2: Ensure PAM Enforces Password Requirements - Minimum Length
    - var_password_pam_minlen=12
    - accounts_password_pam_minlen

    ## RHEL 8 CCE-80653-9: Minimum Digit Characters
    - var_password_pam_dcredit=1
    - accounts_password_pam_dcredit

    ## RHEL 8 CCE-80665-3: Ensure PAM Enforces Password Requirements - Minimum Uppercase Characters
    - var_password_pam_ucredit=1
    - accounts_password_pam_ucredit

    ## RHEL 8 CCE-80655-4: Ensure PAM Enforces Password Requirements - Minimum Lowercase Characters
    - var_password_pam_lcredit=1
    - accounts_password_pam_lcredit

    ## RHEL 8 CCE-80663-8: Ensure PAM Enforces Password Requirements - Minimum Special Characters
    - var_password_pam_ocredit=1
    - accounts_password_pam_ocredit

    ## RHEL 8 CCE-81034-1: Set Password Maximum Consecutive Repeating Characters
    - var_password_pam_maxrepeat=3
    - accounts_password_pam_maxrepeat

    ## RHEL 8 CCE-81034-1: Ensure PAM Enforces Password Requirements - Maximum Consecutive Repeating Characters from Same Character Class
    - var_password_pam_maxclassrepeat=4
    - accounts_password_pam_maxclassrepeat

    ## Set umask Variable for next few rules
    - var_accounts_user_umask=027

    ## RHEL 8 CCE-81035-8: Ensure the Default Umask is Set Correctly in /etc/profile
    - accounts_umask_etc_profile

    ## RHEL 8 CCE-81036-6: Ensure the Default Bash Umask is Set Correctly
    - accounts_umask_etc_bashrc

    ## RHEL 8 CCE-81037-4: Ensure the Default C Shell Umask is Set Correctly
    - accounts_umask_etc_csh_cshrc

    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4475
    # - accounts_umask_etc_login_defs

    #################################################################
    ## PAM Setup
    #################################################################

    ## RHEL 8 CCE-81038-2: Disable Core Dumps for All Users
    - disable_users_coredumps

    ## RHEL 8 CCE-80955-8: Limit the Number of Concurrent Login Sessions Allowed Per User
    - var_accounts_max_concurrent_login_sessions=10
    - accounts_max_concurrent_login_sessions

    ## RANDOM TO DO
    #sed -i "6s/^#//" /etc/pam.d/su
    #sed -i "8iauth        required      pam_faillock.so preauth silent " /etc/pam.d/system-auth
    #sed -i "8iauth        required      pam_faillock.so preauth silent " /etc/pam.d/password-auth

    ## RHEL 8 CCE-80666-1: Limit Password Reuse
    - accounts_password_pam_unix_remember
    - var_password_pam_unix_remember=5

    ## RHEL 8 CCE-80667-9: Set Deny For Failed Password Attempts
    - var_accounts_passwords_pam_faillock_deny=3
    - accounts_passwords_pam_faillock_deny

    ## RHEL 8 CCE-80669-5: Set Interval For Counting Failed Password Attempts
    - var_accounts_passwords_pam_faillock_fail_interval=900
    - accounts_passwords_pam_faillock_interval

    ## RHEL 8 CCE-80670-3: Set Lockout Time for Failed Password Attempts
    - var_accounts_passwords_pam_faillock_unlock_time=never
    - accounts_passwords_pam_faillock_unlock_time


    ## RHEL 8 CCE-80841-0: Prevent Login to Accounts With Empty Password
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

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4476
    #sed -i "/upgrade_type/s/default/security/" /etc/dnf/automatic.conf

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4477
    #sed -i "/apply_updates/s/no/yes/" /etc/dnf/automatic.conf

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4478
    #systemctl enable --now dnf-automatic.timer
