documentation_complete: true

title: 'Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2).

selections:

    #
    # Set the system's root password (required)
    # Plaintext password is: server
    # Refer to https://pykickstart.readthedocs.io/en/latest/commands.html#rootpw
    # to see how to create an encrypted password for a different plaintext password
    #rootpw --iscrypted $6$rhel6usgcb$aS6oPGXcPKp3OtFArSrhRwu6sN8q2.yEGY7AIwDOQd23YCtiz9c5mXbid1BzX9bmXTEZi.hCzTEXFosVBI5ng0

    # This profile will restrict root login. Add a user that can login and
    # change to root.
    # Plaintext password is: admin123
    #user --name=admin --groups=wheel --password=$6$Ga6ZnIlytrWpuCzO$q0LqT1USHpahzUafQM9jyHCY9BiE5/ahXLNWUMiVQnFGblu0WWGZ1e6icTaCGO4GNgZNtspp1Let/qpM7FMVB0 --iscrypted


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

    ## TO DO:  GRUB SETTINGS

    # Specify how the bootloader should be installed (required)
    # Plaintext password is: password  username is: root
    # Refer to grub2-mkpasswd-pbkdf2 man page to see how to create an
    # encrypted password for a different plaintext password.
    #
    # NOTE: If you plan to use containers from older distributions, you MAY
    # remove vsyscall=none from the --append command since older glibc depends
    # on having vsyscalls available.
    #bootloader --location=mbr --append="boot=/dev/vda1 fips=1 audit=1 audit_backlog_limit=8192 slub_debug=P page_poison=1 pti=on vsyscall=none" --iscrypted --password=grub.pbkdf2.sha512.10000.3A8BA0AB351ADA8FAD49BC54A8730AD53F67EA1762E99DF4881FD2FF9CD2A361623DB0AA6FF31A8C0E9731EB60ACA8AE7B2E870BE5D2B9E2CA7DE2EC2A013B3D.4161020F9952809D4F0BF6E0B40795283673769E869B74C52EF2FBFE751A5B0F2B149B409922D6EB1073ABEC531696F92AA8B8A5A7CA2F575D3BBBDA0BFC1A98

    # Create primary system partitions (required for installs)
    #part /boot --fstype=xfs --size=512 --fsoptions="nodev,nosuid"

    ## RHEL 8 CCE-81044-0: Ensure /home Located On Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4484
    ##  unclear if partition requirements still relevant
    - partition_for_home

    ## RHEL 8 CCE-81050-7: Add nosuide Option to /home
    - mount_option_home_nosuid

    ## RHEL 8 CCE-80852-7: Ensure /var Located on Separate Partition
    ## SEE ALSO: https://github.com/ComplianceAsCode/content/issues/4486
    ##  unclear if partition requirements still exist
    - partition_for_var

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4489
    #logvol /var --fstype=xfs --name=var --vgname=VolGroup --size=2048 --fsoptions="nodev"

    ## RHEL 8 CCE-80853-5: Ensure /var/log Located on Separate Partition
    - partition_for_var_log

    ## /var/log nosuid
    ## /var/log noexec

    ## RHEL 8 CCE-80854-3: Ensure /var/log/audit Located on Separate Partition
    - partition_for_var_log_audit

    # audit nosuid
    # audit noexec

    ## RHEL 8 CCE-81053-1: Add nodev Option to /var/tmp
    - mount_option_var_tmp_nodev

    ## audit nosuid
    ## audit noexec

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4490
    ##  do we need a swap partition (for security reasons)?
    #logvol swap --name=lv_swap --vgname=VolGroup --size=2016

    ## RHEL 8 CCE-81054-9: Add nodev Option to Non-Root Local Partitions
    - mount_option_nodev_nonroot_local_partitions


    ## Setup a couple mountpoints by hand to ensure correctness
    #touch /etc/fstab
    ## CCE-26435-8: Ensure /tmp Located On Separate Partition
    #echo -e "tmpfs\t/tmp\t\t\t\ttmpfs\tdefaults,mode=1777,noexec,nosuid,nodev,strictatime,size=512M\t0 0" >> /etc/fstab

    ## Make sure /dev/shm is restricted
    #echo -e "tmpfs\t/dev/shm\t\t\t\ttmpfs\tdefaults,mode=1777,noexec,nosuid,nodev,strictatime\t0 0" >> /etc/fstab


    ################################################
    ## MUST INSTALL PACKAGES IN BASE MODE

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4483
    #cryptsetup-luks
    #sssd-ipa
    #aide
    #binutils
    #dnf-automatic
    #firewalld
    #iptables
    #libcap-ng-utils
    #openscap-scanner
    #policycoreutils
    #python-rhsm
    #rng-tools
    #sudo
    #tar
    #tmux
    #usbguard
    #vim
    #audispd-plugins
    #scap-security-guide

    ## RHEL 8 CCE-81043-2: Ensure the audit Subsystem is Installed
    - package_auditd_installed

    ## RHEL 8 CCE-80845-1: Install libreswan Package
    - package_libreswan_installed

    ## RHEL 8 CCE-80847-7: Ensure rsyslog is Installed
    - package_rsyslog_installed



    ################################################
    ## MUST INSTALL PACKAGES IN MLS MODE
    #cups
    #foomatic
    #ghostscript
    #ghostscript-fonts
    #checkpolicy
    #mcstrans
    #policycoreutils-newrole
    #selinux-policy-devel
    ##xinetd
    #iproute
    #iputils
    #netlabel_tools


    #################################################################
    ## Remove Prohibited Packages
    #################################################################

    ## RHEL 8 CCE-81039-0: Uninstall Sendmail Package
    - package_sendmail_removed

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4482
    #-iprutils
    #-gssproxy
    #-geolite2-city
    #-geolite2-country
    #-nfs-utils
    #-krb5-workstation
    #-abrt-addon-kerneloops
    #-abrt-addon-python
    #-abrt-addon-ccpp
    #-abrt-plugin-rhtsupport
    #-abrt-plugin-logger
    #-abrt-plugin-sosreport
    #-abrt-cli
    #-tuned

    ## RHEL 8 CCE-80948-3: Uninstall Automatic Bug Reporting Tool (abrt)
    - package_abrt_removed


    ## TO DO
    #PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH


    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Creation
    ## (open with O_CREAT)
    ##
    #################################################################

    ## RHEL 8 CCE-80962-4: Record Unsuccessful Creation Attempts to Files - openat O_CREAT
    - audit_rules_unsuccessful_file_modification_openat_o_creat

    ## TO DO: Record Successful Creation Attempts to Files - openat O_CREAT
    ##  https://github.com/ComplianceAsCode/content/issues/4557
    #-a always,exit -F arch=b32 -S openat -F a2&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create
    #-a always,exit -F arch=b64 -S openat -F a2&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create

    ## RHEL 8 CCE-80965-7: Record Unsuccessful Creation Attempts to Files - open_by_handle_at O_CREAT
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_creat

    ## TO DO: Record Successful Creation Attempts to Files - open_by_handle_at O_CREAT
    ##  https://github.com/ComplianceAsCode/content/issues/4558
    #-a always,exit -F arch=b32 -S open_by_handle_at -F a2&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create
    #-a always,exit -F arch=b64 -S open_by_handle_at -F a2&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create

    ## RHEL 8 CCE-80968-1: Record Unsuccessful Creation Attempts to Files - open O_CREAT
    - audit_rules_unsuccessful_file_modification_open_o_creat

    ## TO DO: Record Successful Creation Attempts to Files - open O_CREAT
    ##  https://github.com/ComplianceAsCode/content/issues/4559
    #-a always,exit -F arch=b32 -S open -F a1&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create
    #-a always,exit -F arch=b64 -S open -F a1&0100 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-create

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Modifications
    ## (open for write or truncate with O_TRUNC_WRITE)
    ##
    #################################################################

    ## RHEL 8 CCE-80963-2: Record Unsuccessful Modification Attempts to Files - openat O_TRUNC
    - audit_rules_unsuccessful_file_modification_openat_o_trunc_write

    ## TO DO: Record Successful Modification Attempts to Files - openat O_TRUNC
    ##  https://github.com/ComplianceAsCode/content/issues/4561
    #-a always,exit -F arch=b32 -S openat -F a2&01003 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-modification
    #-a always,exit -F arch=b64 -S openat -F a2&01003 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-modification

    ## RHEL 8 CCE-80966-5: Record Unsuccessful Modification Attempts to Files - open_by_handle_at O_TRUNC
    - audit_rules_unsuccessful_file_modification_open_by_handle_at_o_trunc_write

    ## TO DO: Record Successful Modification Attempts to Files - open_by_handle_at O_TRUNC
    ##  https://github.com/ComplianceAsCode/content/issues/4562
    #-a always,exit -F arch=b32 -S open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification
    #-a always,exit -F arch=b64 -S open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification

    ## RHEL 8 CCE-80969-9: Record Unsuccessful Modification Attempts to Files - open O_TRUNC
    - audit_rules_unsuccessful_file_modification_open_o_trunc_write

    ## TO DO: Record Successful Modification Attempts to Files - open O_TRUNC
    ##  https://github.com/ComplianceAsCode/content/issues/4560
    #-a always,exit -F arch=b32 -S open -F a1&01003 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-modification
    #-a always,exit -F arch=b64 -S open -F a1&01003 -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-modification


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

    ## TO DO: Record Successful Access Attempts to Files - open
    ##  https://github.com/ComplianceAsCode/content/issues/4549
    #-a always,exit -F arch=b32 -S open -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S open -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    ## RHEL 8 CCE-80751-1: Record Unsuccessful Access Attempts to Files - creat
    - audit_rules_unsuccessful_file_modification_creat

    ## TO DO: Record Successful Access Attempts to Files - creat
    ##  https://github.com/ComplianceAsCode/content/issues/4552
    #-a always,exit -F arch=b32 -S creat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S creat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    ## RHEL 8 CCE-80756-0: Record Unsuccessful Access Attempts to Files - truncate
    - audit_rules_unsuccessful_file_modification_truncate

    ## TO DO: Record Successful Access Attempts to Files - truncate
    ##  https://github.com/ComplianceAsCode/content/issues/4553
    #-a always,exit -F arch=b32 -S truncate -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S truncate -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    ## RHEL 8 CCE-80752-9: Record Unsuccessful Access Attempts to Files - ftruncate
    - audit_rules_unsuccessful_file_modification_ftruncate

    ## TO DO: Record Successful Access Attempts to Files - ftruncate
    ##  https://github.com/ComplianceAsCode/content/issues/4554
    #-a always,exit -F arch=b32 -S ftruncate -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S ftruncate -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    ## RHEL 8 CCE-80754-5: Record Unsuccessful Access Attempts to Files - openat
    - audit_rules_unsuccessful_file_modification_openat

    ## TO DO: Record Successful Access Attempts to Files - openat
    ##  https://github.com/ComplianceAsCode/content/issues/4555
    #-a always,exit -F arch=b32 -S openat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S openat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    ## RHEL 8 CCE-80755-2: Record Unsuccessful Access Attempts to Files - open_by_handle_at
    - audit_rules_unsuccessful_file_modification_open_by_handle_at

    ## TO DO: Record Successful Access Attempts to Files - open_by_handle_at
    ##  https://github.com/ComplianceAsCode/content/issues/4556
    #-a always,exit -F arch=b32 -S open_by_handle_at -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access
    #-a always,exit -F arch=b64 -S open_by_handle_at -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-access

    #################################################################
    ##
    ## Audit Successful/Unsuccessful File Delete
    ##
    #################################################################

    ## RHEL 8 CCE-80971-5: Record Unsuccessful Delete Attempts to Files - unlink
    - audit_rules_unsuccessful_file_modification_unlink

    ## TO DO: Record Successful Delete Attempts to Files - unlink
    ##  https://github.com/ComplianceAsCode/content/issues/4549
    #-a always,exit -F arch=b32 -S unlink -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete
    #-a always,exit -F arch=b64 -S unlink -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete

    ## RHEL 8 CCE-80972-3: Record Unsuccessful Delete Attempts to Files - unlinkat
    - audit_rules_unsuccessful_file_modification_unlinkat

    ## TO DO: Record Successful Delete Attempts to Files - unlinkat
    ##  https://github.com/ComplianceAsCode/content/issues/4548
    #-a always,exit -F arch=b32 -S unlinkat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete
    #-a always,exit -F arch=b64 -S unlinkat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete

    ## RHEL 8 CCE-80973-1: Record Unsuccessful Delete Attempts to Files - rename
    - audit_rules_unsuccessful_file_modification_rename

    ## TO DO: Record Successful Delete Attempts to Files - rename
    ##  https://github.com/ComplianceAsCode/content/issues/4550
    #-a always,exit -F arch=b32 -S rename -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete
    #-a always,exit -F arch=b64 -S rename -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete

    ## RHEL 8 CCE-80974-9: Record Unsuccessful Delete Attempts to Files - renameat
    - audit_rules_unsuccessful_file_modification_renameat

    ## TO DO: Record Successful Delete Attempts to Files - renameat
    ##  https://github.com/ComplianceAsCode/content/issues/4551
    #-a always,exit -F arch=b32 -S renameat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete
    #-a always,exit -F arch=b64 -S renameat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-delete

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Permission Change
    ##
    #################################################################

    ## RHEL 8 CCE-80975-6: Record Unsuccessul Permission Changes to Files - chmod
    - audit_rules_unsuccessful_file_modification_chmod

    ## TO DO: Record Successful Permission Changes to Files - chmod
    ##  https://github.com/ComplianceAsCode/content/issues/4533
    #-a always,exit -F arch=b32 -S chmod -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S chmod -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80977-2: Record Unsuccessul Permission Changes to Files - fchmod
    - audit_rules_unsuccessful_file_modification_fchmod

    ## TO DO: Record Successful Permission Changes to Files - fchmod
    ##  https://github.com/ComplianceAsCode/content/issues/4534
    #-a always,exit -F arch=b32 -S fchmod -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fchmod -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80976-4: Record Unsuccessul Permission Changes to Files - fchmodat
    - audit_rules_unsuccessful_file_modification_fchmodat

    ## TO DO: Record Successful Permission Changes ot Files - fchmodat
    ##  https://github.com/ComplianceAsCode/content/issues/4535
    #-a always,exit -F arch=b32 -S fchmodat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fchmodat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80983-0: Record Unsuccessul Permission Changes to Files - setxattr
    - audit_rules_unsuccessful_file_modification_setxattr

    ## TO DO: Record Successful Permission Changes ot Files - setxattr
    ##  https://github.com/ComplianceAsCode/content/issues/4536
    #-a always,exit -F arch=b32 -S setxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S setxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80981-4: Record Unsuccessul Permission Changes to Files - lsetxattr
    - audit_rules_unsuccessful_file_modification_lsetxattr

    ## TO DO: Record Successful Permission Changes ot Files - lsetxattr
    ##  https://github.com/ComplianceAsCode/content/issues/4537
    #-a always,exit -F arch=b32 -S lsetxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S lsetxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80979-8: Record Unsuccessul Permission Changes to Files - fsetxattr
    - audit_rules_unsuccessful_file_modification_fsetxattr

    ## TO DO: Record Successful Permission Changes ot Files - fsetxattr
    ##  https://github.com/ComplianceAsCode/content/issues/4538
    #-a always,exit -F arch=b32 -S fsetxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fsetxattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80982-2: Record Unsuccessul Permission Changes to Files - removexattr
    - audit_rules_unsuccessful_file_modification_removexattr

    ## TO DO: Record Successful Permission Changes ot Files - removexattr
    ##  https://github.com/ComplianceAsCode/content/issues/4538
    #-a always,exit -F arch=b32 -S removexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S removexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80980-6: Record Unsuccessul Permission Changes to Files - lremovexattr
    - audit_rules_unsuccessful_file_modification_lremovexattr

    ## TO DO: Record Successful Permission Changes ot Files - lremovexattr
    ##  https://github.com/ComplianceAsCode/content/issues/4539
    #-a always,exit -F arch=b32 -S lremovexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S lremovexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80978-0: Record Unsuccessul Permission Changes to Files - fremovexattr
    - audit_rules_unsuccessful_file_modification_fremovexattr

    ## TO DO: Record Successful Permission Changes ot Files - fremovexattr
    ##  https://github.com/ComplianceAsCode/content/issues/4540
    #-a always,exit -F arch=b32 -S fremovexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fremovexattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    #################################################################
    ##
    ## Audit Successful/Unsuccessful Ownership Change
    ##
    #################################################################

    ## RHEL 8 CCE-80987-1: Record Unsuccessul Ownership Changes to Files - lchown
    - audit_rules_unsuccessful_file_modification_lchown

    ## TO DO: Record Successful Ownership Changes to Files - lchown
    ##  https://github.com/ComplianceAsCode/content/issues/4519
    #-a always,exit -F arch=b32 -S lchown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S lchown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80986-3: Record Unsuccessul Ownership Changes to Files - fchown
    - audit_rules_unsuccessful_file_modification_fchown

    ## TO DO: Record Successful Ownership Changes to Files - fchown
    ##  https://github.com/ComplianceAsCode/content/issues/4521
    #-a always,exit -F arch=b32 -S fchown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fchown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80984-8: Record Unsuccessul Ownership Changes to Files - chown
    - audit_rules_unsuccessful_file_modification_chown

    ## TO DO: Record Successful Ownership Changes to Files - chown
    ##  https://github.com/ComplianceAsCode/content/issues/4522
    #-a always,exit -F arch=b32 -S chown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S chown -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change

    ## RHEL 8 CCE-80985-5: Record Unsuccessul Ownership Changes to Files - fchownat
    - audit_rules_unsuccessful_file_modification_fchownat

    ## TO DO: Record Successful Ownership Changes to Files - fchownat
    ##  https://github.com/ComplianceAsCode/content/issues/4523
    #-a always,exit -F arch=b32 -S fchownat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change
    #-a always,exit -F arch=b64 -S fchownat -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change


    #################################################################
    ##
    ## Audit User Add, Delete, Modify
    ##
    ## This is covered by PAM. However, someone could open a file
    ## and directly create of modify a user, so we'll watch
    ## passwd and shadow for writes.
    ##
    #################################################################
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4517
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

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4513
    #-a always,exit -F path=/usr/sbin/seunshare -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes
    
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

    ## RHEL 8 CCE-80795-8: Ensure Red Hat GPG Key Installed
    - ensure_redhat_gpgkey_installed

    #################################################################
    ## Kernel Security Settings
    #################################################################

    ## RHEL 8 CCE-80915-2: Restrict Exposed Kernel Pointer Addresses Access
    - sysctl_kernel_kptr_restrict

    ## RHEL 8 CCE-80913-7: Restrict Access to Kernel Message Buffer
    - sysctl_kernel_dmesg_restrict

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4491
    #echo "kernel.perf_event_paranoid = 2" >> $CONFIG

    ## RHEL 8 CCE-80952-5: Disable Kernel Image Loading
    - sysctl_kernel_kexec_load_disabled

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4492
    #echo "# If you know you are have containers that need user namespaces," >> $CONFIG
    #echo "# you MAY comment out the next line." >> $CONFIG
    #echo "user.max_user_namespaces = 0" >> $CONFIG

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4493
    #echo "kernel.unprivileged_bpf_disabled = 1" >> $CONFIG

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4494
    #echo "net.core.bpf_jit_harden = 2" >> $CONFIG

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

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4455
    ## echo -e "install firewire-core /bin/true" >> $CONFIG

    ## RHEL 8 CCE-81031-7: Disable Mounting of cramfs
    - kernel_module_cramfs_disabled

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4456
    ## echo -e "install atm /bin/true" >> $CONFIG

    ## RHEL 8 CCE-80832-9: Disable Bluetooth Kernel Module
    - kernel_module_bluetooth_disabled
    
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4457
    ## echo -e "install can /bin/true" >> $CONFIG

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

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4459
    ## systemctl mask debug-shell.service

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

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4465
    #echo -e "port 0" >> $CONFIG

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

    #################################################################
    ## Enable / Configure USB Guard
    #################################################################
    
    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4473
    #sed -i "/AuditBackend/s/FileAudit/LinuxAudit/" /etc/usbguard/usbguard-daemon.conf

    ## TO DO: HOW TO HANDLE??
    #setup_usbguard

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4474
    #systemctl enable usbguard

    ## RHEL 8 CCE-80942-6: Enable FIPS Mode
    - enable_fips_mode

    ## TO DO: https://github.com/ComplianceAsCode/content/issues/4500
    # - sysctl_crypto_fips_enabled
    # - enable_dracut_fips_module
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
    - accounts_password_pam_dcredit

    ## RHEL 8 CCE-80665-3: Ensure PAM Enforces Password Requirements - Minimum Uppercase Characters
    - accounts_password_pam_ucredit

    ## RHEL 8 CCE-80655-4: Ensure PAM Enforces Password Requirements - Minimum Lowercase Characters
    - accounts_password_pam_lcredit

    ## RHEL 8 CCE-80663-8: Ensure PAM Enforces Password Requirements - Minimum Special Characters
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
    #sed -i "8iauth        required      pam_faillock.so preauth silent deny=3 unlock_time=never fail_interval=900" /etc/pam.d/system-auth
    #sed -i "8iauth        required      pam_faillock.so preauth silent deny=3 unlock_time=never fail_interval=900" /etc/pam.d/password-auth
    #sed -i "/pam_unix/s/$/ remember=5/" /etc/pam.d/system-auth

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
