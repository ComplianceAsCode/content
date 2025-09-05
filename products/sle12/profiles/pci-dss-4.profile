documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4 Control Baseline for SUSE Linux enterprise 12'

description: |-
    Ensures PCI-DSS v4 security configuration settings are applied.

selections:
    -  pcidss_3:all:base
    -  account_unique_id
    -  coredump_disable_backtraces
    -  coredump_disable_storage
    -  disable_host_auth
    -  disable_prelink
    -  disable_users_coredumps
    -  file_at_deny_not_exist
    -  file_cron_deny_not_exist
    -  file_groupowner_at_allow
    -  file_groupowner_backup_etc_group
    -  file_groupowner_backup_etc_passwd
    -  file_groupowner_backup_etc_shadow
    -  file_groupowner_cron_allow
    -  file_owner_at_allow
    -  file_owner_backup_etc_group
    -  file_owner_backup_etc_passwd
    -  file_owner_backup_etc_shadow
    -  file_owner_cron_allow
    -  file_permissions_at_allo
    -  file_permissions_backup_etc_group
    -  file_permissions_backup_etc_passwd
    -  file_permissions_backup_etc_shadow
    -  file_permissions_cron_allow
    -  file_permissions_cron_daily
    -  file_permissions_cron_daily
    -  file_permissions_cron_hourly
    -  file_permissions_cron_monthly
    -  file_permissions_cron_weekly
    -  file_permissions_crontab
    -  file_permissions_etc_group
    -  file_permissions_etc_shadow
    -  file_permissions_sshd_config
    -  file_permissions_unauthorized_world_writable
    -  file_permissions_ungroupowned
    -  group_unique_id
    -  group_unique_name
    -  no_files_unowned_by_user
    -  package_bind_removed
    -  package_dhcp_removed
    -  package_httpd_removed
    -  package_net-snmp_removed
    -  package_nfs-utils_removed
    -  package_openldap-servers_removed
    -  package_rsh_removed
    -  package_samba_removed
    -  package_talk_removed
    -  package_telnet_removed
    -  package_xinetd_removed
    -  package_ypbind_removed
    -  service_avahi-daemon_disabled
    -  service_cron_enabled
    -  service_cups_disabled
    -  service_rpcbind_disabled
    -  service_rsyncd_disabled
    -  sshd_disable_rhosts
    -  sshd_disable_tcp_forwarding
    -  sshd_disable_x11_forwarding
    -  sshd_enable_pam
    -  sshd_set_max_auth_tries
    -  sshd_set_max_sessions
    -  sshd_set_maxstartups
    -  sshd_use_approved_ciphers
    -  sshd_use_approved_macs
    -  sysctl_fs_suid_dumpable
    
