# Don't forget to enable build of tables in rhel7CMakeLists.txt when setting to true
documentation_complete: true

title: 'DRAFT - ANSSI DAT-NT28 (intermediary)'

description: 'Draft profile for ANSSI compliance at the intermediary level. ANSSI stands for Agence nationale de la sécurité
    des systèmes d''information. Based on https://www.ssi.gouv.fr/.'

extends: anssi_nt28_minimal

selections:

    # ==============================================
    # R2 - Minimization of configuration
    # The features configured at the level of launched services should be limited
    # to the strict minimum.

    # ==============================================
    # R9 - Hardware configuration
    # The features configured at the level of launched services should be limited
    # to the strict minimum.

    # ==============================================
    # R10 - 32 and 64 bit architecture
    # When the machine supports it, prefer the installation of a GNU / Linux
    # distribution in 64-bit version instead of 32-bit version

    # ==============================================
    # R12 - Partitioning type
    # The recommended partitioning type is as follows:
    # / <without option> Root partition, contains the rest of the tree
    # /boot nosuid, nodev, noexec (optional noauto) Contains the kernel and the bootloader. No access required once the boot finished (except update)
    # /opt nosuid, nodev (optional ro) Additional packages to the system.  Read-only editing if not used
    # /tmp nosuid, nodev, noexec Temporary files. Must contain only non-executable elements. Cleaned after reboot
    - partition_for_tmp
    - mount_option_tmp_nosuid
    - mount_option_tmp_nodev
    - mount_option_tmp_noexec

    # /srv nosuid, nodev (noexec, optional ro) Contains files served by a service type web, ftp, etc
    # /home nosuid, nodev, noexec Contains the HOME users.  Read-only editing if not in use
    - partition_for_home
    - mount_option_home_nosuid
    - mount_option_home_nodev

    # /proc hidepid = 1 Contains process information and the system
    # /usr nodev Contains the majority of utilities and system files
    # /var nosuid, nodev, noexec Partition containing variable files during the life of the system (mails, PID files, databases of a service)
    - partition_for_var

    # /var/log nosuid, nodev, noexec Contains system logs
    - partition_for_var_log

    # /var/tmp nosuid, nodev, noexec Temporary files kept after extinction
    - partition_for_var_tmp
    - mount_option_var_tmp_nosuid
    - mount_option_var_tmp_nodev
    - mount_option_var_tmp_noexec

    # ==============================================
    # R14 - Installation of packages reduced to the bare necessities
    # The choice of packages should lead to an installation as small as possible,
    # limiting itself to select only what is required as needed.

    # ==============================================
    # R19 - Accountability of administration
    # Each administrator must have a dedicated account (local or remote), and not use the root
    # account as the access account for system administration.
    #
    # Change of privilege operations must be based on executables to monitor the activities
    # performed (for example sudo).
    - no_direct_root_logins
    - sshd_disable_root_login

    # ==============================================
    # R21 - Hardening and monitoring of services subject to arbitrary flows
    # Services exposed to uncontrolled flows must be monitored and particularly hardened.
    # Monitoring consists of characterizing the behavior of the service, and
    # reporting all deviation from its nominal operation (this one being deduced
    # from the initial expected specifications).


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
    # R27 - Disabling service accounts
    # Service accounts must be disabled.

    # ==============================================
    # R31 - Securing PAM Authentication Network Services
    # When authentication takes place through a remote service (network), the
    # authentication  protocol used by PAM must be secure (flow encryption,
    # remote server authentication, anti-replay mechanisms, etc.).

    # ==============================================
    # R33 - Securing access to remote user databases
    # When the user databases are stored on a remote network service (LDAP type),
    # NSS must be configured to establish a secure link that allows at minimum
    # to authenticate the server and protect the communication channel.

    # ==============================================
    # R34 - Separation of System Accounts and Directory Administrator
    # It is recommended not to have overlapping account recovery between those
    # used by the operating system and those used to administer the directory.
    # Using directory administrator accounts to perform enumeration queries accounts
    # by NSS must be prohibited.

    # ==============================================
    # R36 - Rights to access sensitive content files
    # Sensitive content files should only be readable by users with strict need to know.
    - file_owner_etc_shadow
    - file_permissions_etc_shadow
    - file_owner_etc_gshadow
    - file_permissions_etc_gshadow
    - file_permissions_etc_passwd
    - file_permissions_etc_group

    # ==============================================
    # R39 - Temporary directories dedicated to accounts
    # Each user or service account must have its own temporary directory and
    # dispose of it exclusively.

    # ==============================================
    # R40 - Sticky bit and write access rights
    # All writable directories must have all the sticky bit armed.

    # ==============================================
    # R41 - Securing access for named sockets and pipes
    # Named pipes and sockets must be protected access a directory with Appropriate rights.

    # ==============================================
    # R43 - Hardening and configuring the syslog
    # The chosen syslog server must be hardened according to the security guides
    # associated with this server. The configuration of the service must be performed
    # according to the Security Recommendations for the implementation of a logging
    # system accessible on the site of ANSSI.
    - rsyslog_files_ownership
    - rsyslog_files_groupownership
    - rsyslog_files_permissions
    - ensure_logrotate_activated
    - rsyslog_remote_loghost

    # ==============================================
    # R44 - Partitioning the syslog service by chroot
    # When the technical means and its configuration allow it, the syslog service
    # must to be locked in a chroot environment.

    # ==============================================
    # R46 - Service Activity Logs
    # Each service must have a dedicated logging journal on the system. This file
    # should only be accessible only through the syslog server, and should not
    # be readable, editable or deletable by the service directly.

    # ==============================================
    # R47 - Dedicated partition for logs
    # The logs must be in a separate partition from the rest of the system.

    # ==============================================
    # R48 - Configuring the local messaging service
    # When a mail service is installed on the machine, it must be configured
    # for that he accepts only:
    # * mails to a local user at the machine;
    # * connections through the local loop (remote connections to the mail
    # service must be rejected).

    # ==============================================
    # R49 - Messaging Aliases for Service Accounts
    # For each service running on the machine, as well as the root account, an
    # email alias to an administrator user must be configured to receive
    # notifications and reports sent via email.

    # ==============================================
    # R55 - chroot jail and access right for partitioned service
    # The chroot jail of a service must only contain the strict minimum to run
    # the service properly.
    # When locked in the chroot jail, the service must always run with the
    # privileges of a normal user (non root), dedicated user (whose identity is
    # used uniquely by the jail) and with no write access to this new root.

    # ==============================================
    # R56 - Enablement and usage of chroot by a service
    # chroot must be used and enabled when the service implements this mechanism

    # ==============================================
    # R57 - Group dedicated to the use of sudo
    # A group dedicated to the use of sudo must be created. Only the users member
    # of this group should have the right to run sudo.

    # ==============================================
    # R58 - Sudo configuration guidelines
    # The following guidelines must be enabled by default:
    # noexec                apply the NOEXEC tag by default on the commands;
    # requiretty            require the user to have a tty  login;
    # use_pty               using a pseudo-tty when a command is executed;
    # umask = 0027          force umask to a more restrictive mask;
    # ignore_dot            ignores the ‘.’ in $ PATH;
    # env_reset             reset the environment variables;
    # passwd_timeout = 1    allocate 1 minute to enter its password.

    # ==============================================
    # R60 - Privileges of target sudo users
    # The targeted users of a rule should be as far as possible be a non
    # privileged user (i.e.: non root)

    # ==============================================
    # R62 - Good use of negation in a sudoers file
    # Policies applied by sudo through the sudoers file should not involve negation.

    # ==============================================
    # R63 - Explicit arguments in sudo specifications
    # All commands in the sudoers file must strictly specify the arguments
    # allowed to be used for a given user.
    # The use of * (wildcard) in the rules should be avoided as much as possible.
    # The absence of arguments in a command must be specified by the presence
    # of an empty chain ( "").

    # ==============================================
    # R64 - Good use of sudoedit
    # Editing a file with sudo must be done through the command sudoedit.
