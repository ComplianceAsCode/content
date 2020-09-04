documentation_complete: true

title: 'ANSSI BP-028 (intermediary)'

description: 
    ANSSI BP-028 compliance at the intermediary level. ANSSI stands for
    Agence nationale de la sécurité des systèmes d''information. Based on
    https://www.ssi.gouv.fr/.

extends: anssi_bp28_minimal

selections:
    # Minimization of configuration

    # 32 and 64 bit architecture

    # Partitioning type
    - partition_for_tmp
    - mount_option_tmp_nosuid
    - mount_option_tmp_nodev
    - mount_option_tmp_noexec
    - partition_for_home
    - mount_option_home_nosuid
    - mount_option_home_nodev
    - partition_for_var
    - partition_for_var_log
    - partition_for_var_tmp
    - mount_option_var_tmp_nosuid
    - mount_option_var_tmp_nodev
    - mount_option_var_tmp_noexec

    # Installation of packages reduced to the bare necessities

    # Accountability of administration
    - no_direct_root_logins
    - sshd_disable_root_login

    # Hardening and monitoring of services subject to arbitrary flows

    # Setting up network sysctl
    - sysctl_net_ipv4_ip_forward
    - sysctl_net_ipv4_conf_all_rp_filter
    - sysctl_net_ipv4_conf_default_rp_filter
    - sysctl_net_ipv4_conf_all_send_redirects
    - sysctl_net_ipv4_conf_default_send_redirects
    - sysctl_net_ipv4_conf_all_accept_source_route
    - sysctl_net_ipv4_conf_default_accept_source_route
    - sysctl_net_ipv4_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_all_accept_redirects
    - sysctl_net_ipv4_conf_all_secure_redirects
    - sysctl_net_ipv4_conf_default_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_accept_redirects
    - sysctl_net_ipv4_conf_default_secure_redirects
    - sysctl_net_ipv4_conf_all_log_martians
    # net.ipv4.tcp_rfc1337 = 1
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses
    # net.ipv4.ip_local_port_ranges = 32768 65535
    - sysctl_net_ipv4_tcp_syncookies
    # net.ipv6.conf.all.router_solicitations = 0
    # net.ipv6.conf.default.router_solicitations = 0
    # net.ipv6.conf.all.accept_ra_rtr_pref = 0
    # net.ipv6.conf.default.accept_ra_rtr_pref = 0
    # net.ipv6.conf.all.accept_ra_pinfo = 0
    # net.ipv6.conf.default.accept_ra_pinfo = 0
    # net.ipv6.conf.all.accept_ra_defrtr = 0
    # net.ipv6.conf.default.accept_ra_defrtr = 0
    # net.ipv6.conf.all.autoconf = 0
    # net.ipv6.conf.default.autoconf = 0
    # net.ipv6.conf.all_accept_redirects = 0
    - sysctl_net_ipv6_conf_all_accept_redirects
    - sysctl_net_ipv6_conf_default_accept_redirects
    - sysctl_net_ipv6_conf_all_accept_source_route
    - sysctl_net_ipv6_conf_default_accept_source_route
    # net.ipv6.conf.all.max_addresses = 1
    # net.ipv6.conf.default.max_addresses = 1

    # Setting system sysctl
    - sysctl_fs_suid_dumpable
    - sysctl_fs_protected_symlinks
    - sysctl_fs_protected_hardlinks
    - sysctl_kernel_randomize_va_space
    # vm.mmap_min_addr = 65536
    # kernel.pid_max = 65536
    - sysctl_kernel_kptr_restrict
    - sysctl_kernel_dmesg_restrict
    - sysctl_kernel_perf_event_paranoid
    # kernel.perf_event_paranoid = 2
    # kernel.perf_event_max_sample_rate = 1
    # kernel.perf_cpu_time_max_percent = 1

    # Disabling service accounts

    # Securing PAM Authentication Network Services

    # Securing access to remote user databases

    # Rights to access sensitive content files
    # Sensitive content files should only be readable by users with strict need to know.
    - file_owner_etc_shadow
    - file_permissions_etc_shadow
    - file_owner_etc_gshadow
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_group

    # Temporary directories dedicated to accounts

    # Sticky bit and write access rights

    # All writable directories must have all the sticky bit armed.


    # Securing access for named sockets and pipes

    # Hardening and configuring the syslog
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - ensure_logrotate_activated
    - rsyslog_remote_loghost

    # Partitioning the syslog service by chroot
    
    # Service Activity Logs

    # Dedicated partition for logs

    # Configuring the local messaging service

    # Messaging Aliases for Service Accounts

    # chroot jail and access right for partitioned service

    # Enablement and usage of chroot by a service

    # Group dedicated to the use of sudo

    # Sudo configuration guidelines

    # Privileges of target sudo users

    # Good use of negation in a sudoers file

    # Explicit arguments in sudo specifications
