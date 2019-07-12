# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (intermediary)'

description: 'Draft profile for ANSSI compliance at the intermediary level. ANSSI stands for Agence nationale de la sécurité
    des systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_minimal

selections:

    # ==============================================
    # R12 Partitioning
    - partition_for_tmp
    - mount_option_tmp_nosuid
    - mount_option_tmp_nodev
    - mount_option_tmp_noexec
    - partition_for_var
    - partition_for_var_tmp
    - mount_option_var_tmp_nosuid
    - mount_option_var_tmp_nodev
    - mount_option_var_tmp_noexec
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_home
    - mount_option_home_nosuid
    - mount_option_home_nodev

    - sshd_idle_timeout_value=5_minutes
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - ensure_logrotate_activated

    # ==============================================
    # R19  - Accountability of administration
    # Each administrator must have a dedicated account (local or remote), and not use the root
    # account as the access account for system administration.
    #
    # Change of privilege operations must be based on executables to monitor the activities
    # performed (for example sudo).
    - no_direct_root_logins
    - sshd_disable_root_login

    # ==============================================
    # R22 - Setting up network sysctl
    # These sysctl are given for a typical host "server" that does not perform routing and
    # having a minimal IPv6 configuration (static addressing). When IPv6 is not used it should
    # be disabled by setting the option net.ipv5.all.disable_ipv6 to 1. They are shown
    # here as encountered in the sysctl.conf file;
    #
    # No routing between interfaces
    # net.ipv4.ip_forward = 0
    - sysctl_net_ipv4_ip_forward

    # Reverse path filtering
    # net.ipv4.conf.all.rp_filter = 1
    - sysctl_net_ipv4_conf_all_rp_filter

    # net.ipv4.conf.default.rp_filter = 1
    - sysctl_net_ipv4_conf_default_rp_filter

    # Do not send ICMP redirects
    # net.ipv4.conf.all.send_redirects = 0
    - sysctl_net_ipv4_conf_all_send_redirects

    # net.ipv4.conf.default.send_redirects = 0
    - sysctl_net_ipv4_conf_default_send_redirects

    # Deny source routing packets
    # net.ipv4.conf.all.accept_source_route = 0
    - sysctl_net_ipv4_conf_all_accept_source_route

    # net.ipv4.conf.default.accept_source_route = 0
    - sysctl_net_ipv4_conf_default_accept_source_route

    # Do not accept ICMPs of redirect type
    # net.ipv4.conf.all.accept_redirects = 0
    - sysctl_net_ipv4_conf_all_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_all_accept_redirects

    # net.ipv4.conf.all.secure_redirects = 0
    - sysctl_net_ipv4_conf_all_secure_redirects

    # net.ipv4.conf.default.accept_redirects = 0
    - sysctl_net_ipv4_conf_default_accept_redirects_value=disabled
    - sysctl_net_ipv4_conf_default_accept_redirects

    # net.ipv4.conf.default.secure_redirects = 0
    - sysctl_net_ipv4_conf_default_secure_redirects

    # Log packets with abnormal IPs
    # net.ipv4.conf.all.log_martians = 1
    - sysctl_net_ipv4_conf_all_log_martians

    # RFC 1337
    # net.ipv4.tcp_rfc1337 = 1

    # Ignore responses that do not comply with RFC 1122
    # net.ipv4.icmp_ignore_bogus_error_responses = 1
    - sysctl_net_ipv4_icmp_ignore_bogus_error_responses

    # Increase the range for ephemeral ports
    # net.ipv4.ip_local_port_ranges = 32768 65535
    
    # Use SYN cookies
    # net.ipv4.tcp_syncookies = 1
    - sysctl_net_ipv4_tcp_syncookies

    # Disable support for "router solicitations"
    # net.ipv6.conf.all.router_solicitations = 0
    # net.ipv6.conf.default.router_solicitations = 0
    
    # Do not accept "router preferences" by "router advertisements"
    # net.ipv6.conf.all.accept_ra_rtr_pref = 0
    # net.ipv6.conf.default.accept_ra_rtr_pref = 0

    # No auto configuration of prefixes by router advertisements
    # net.ipv6.conf.all.accept_ra_pinfo = 0
    # net.ipv6.conf.default.accept_ra_pinfo = 0

    # No default router learning by router advertisements
    # net.ipv6.conf.all.accept_ra_defrtr = 0
    # net.ipv6.conf.default.accept_ra_defrtr = 0

    # No auto configuration of addresses from "routers" advertisements
    # net.ipv6.conf.all.autoconf = 0
    # net.ipv6.conf.default.autoconf = 0

    # Do not accept ICMPs of redirect type
    # net.ipv6.conf.all_accept_redirects = 0
    - sysctl_net_ipv6_conf_all_accept_redirects

    # net.ipv6.conf.default.accept_redirects = 0
    - sysctl_net_ipv6_conf_default_accept_redirects

    # Deny routing source packets
    # net.ipv6.conf.all.accept_source_route = 0
    - sysctl_net_ipv6_conf_all_accept_source_route

    # net.ipv6.conf.default.accept_source_route = 0
    - sysctl_net_ipv6_conf_default_accept_source_route

    # Maximum number of autoconfigured addresses per interface
    # net.ipv6.conf.all.max_addresses = 1
    # net.ipv6.conf.default.max_addresses = 1

    # ==============================================
    #  R23 - Setting system sysctl
    # Here is a list of recommended system sysctl (in the format /etc/sysctl.conf):
    # Disabling SysReq
    # kernel. sysrq = 0

    # No core dump of executable setuid
    - sysctl_fs_suid_dumpable

    # Prohibit links to find links to files
    # the current user is not the owner
    # Can prevent some programs from working properly
    - sysctl_fs_protected_symlinks
    - sysctl_fs_protected_hardlinks

    # Activation of the ASLR
    - sysctl_kernel_randomize_va_space

    # Prohibit mapping of memory in low addresses (0)
    # vm.mmap_min_addr = 65536

    # Larger choice space for PID values
    # kernel.pid_max = 65536

    # Obfuscation of addresses memory kernel
    - sysctl_kernel_kptr_restrict

    # Access restriction to the dmesg buffer
    - sysctl_kernel_dmesg_restrict

    # Disallow kernel profiling by unprivileged users
    - sysctl_kernel_perf_event_paranoid

    # Restricts the use of the perf system
    # kernel.perf_event_paranoid = 2
    # kernel.perf_event_max_sample_rate = 1
    # kernel.perf_cpu_time_max_percent = 1

    # ==============================================
    # R36 - Rights to access sensitive content files
    # Sensitive content files should only be readable by users with strict need to know.
    - file_owner_etc_shadow
    - file_permissions_etc_shadow
    - file_owner_etc_gshadow
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_group

