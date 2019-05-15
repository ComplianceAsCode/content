# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: false

title: 'DRAFT - ANSSI DAT-NT28 (intermediary)'

description: 'Draft profile for ANSSI compliance at the intermediary level. ANSSI stands for Agence nationale de la sécurité
    des systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_minimal

selections:
    - partition_for_tmp
    - partition_for_var
    - partition_for_var_log
    - partition_for_var_log_audit
    - partition_for_home
    - sshd_idle_timeout_value=5_minutes
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - ensure_logrotate_activated
    - sysctl_fs_suid_dumpable
    - sysctl_kernel_randomize_va_space

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
