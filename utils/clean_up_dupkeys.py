import re
from pprint import pprint



if __name__ == "__main__":
    paths = [
"linux_os/guide/services/ssh/ssh_server/disable_host_auth/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_disable_compression/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_disable_rhosts/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_disable_user_known_hosts/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_disable_x11_forwarding/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_do_not_permit_user_env/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_enable_pam/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_enable_strictmodes/rule.yml",
"linux_os/guide/services/ssh/ssh_server/sshd_use_priv_separation/rule.yml",
"linux_os/guide/system/accounts/accounts-banners/gui_login_banner/dconf_gnome_banner_enabled/rule.yml",
"linux_os/guide/system/accounts/accounts-pam/set_password_hashing_algorithm/set_password_hashing_algorithm_passwordauth/rule.yml",
"linux_os/guide/system/accounts/accounts-physical/require_emergency_target_auth/rule.yml",
"linux_os/guide/system/accounts/accounts-physical/require_singleuser_auth/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/account_unique_id/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/group_unique_id/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/password_storage/gid_passwd_group_same/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/password_storage/no_empty_passwords/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/root_logins/accounts_no_uid_except_zero/rule.yml",
"linux_os/guide/system/accounts/accounts-restrictions/root_logins/no_shelllogin_for_systemaccounts/rule.yml",
"linux_os/guide/system/accounts/accounts-session/accounts_max_concurrent_login_sessions/rule.yml",
"linux_os/guide/system/accounts/accounts-session/accounts_user_dot_no_world_writable_programs/rule.yml",
"linux_os/guide/system/accounts/accounts-session/accounts_user_interactive_home_directory_exists/rule.yml",
"linux_os/guide/system/accounts/accounts-session/file_groupownership_home_directories/rule.yml",
"linux_os/guide/system/accounts/accounts-session/file_permissions_home_directories/rule.yml",
"linux_os/guide/system/accounts/accounts-session/user_umask/accounts_umask_etc_bashrc/rule.yml",
"linux_os/guide/system/accounts/accounts-session/user_umask/accounts_umask_etc_csh_cshrc/rule.yml",
"linux_os/guide/system/accounts/accounts-session/user_umask/accounts_umask_etc_login_defs/rule.yml",
"linux_os/guide/system/accounts/accounts-session/user_umask/accounts_umask_etc_profile/rule.yml",
"linux_os/guide/system/bootloader-grub2/non-uefi/grub2_admin_username/rule.yml",
"linux_os/guide/system/bootloader-grub2/non-uefi/grub2_password/rule.yml",
"linux_os/guide/system/network/network-ipv6/configuring_ipv6/sysctl_net_ipv6_conf_all_accept_ra/rule.yml",
"linux_os/guide/system/network/network-ipv6/configuring_ipv6/sysctl_net_ipv6_conf_all_accept_source_route/rule.yml",
"linux_os/guide/system/network/network-ipv6/configuring_ipv6/sysctl_net_ipv6_conf_all_forwarding/rule.yml",
"linux_os/guide/system/network/network-ipv6/configuring_ipv6/sysctl_net_ipv6_conf_default_accept_ra/rule.yml",
"linux_os/guide/system/network/network-ipv6/configuring_ipv6/sysctl_net_ipv6_conf_default_accept_source_route/rule.yml",
"linux_os/guide/system/network/network-kernel/network_host_and_router_parameters/sysctl_net_ipv4_conf_all_accept_source_route/rule.yml",
"linux_os/guide/system/network/network-kernel/network_host_and_router_parameters/sysctl_net_ipv4_conf_default_rp_filter/rule.yml",
"linux_os/guide/system/network/network-kernel/network_host_and_router_parameters/sysctl_net_ipv4_icmp_echo_ignore_broadcasts/rule.yml",
"linux_os/guide/system/network/network-kernel/network_host_parameters/sysctl_net_ipv4_conf_all_send_redirects/rule.yml",
"linux_os/guide/system/network/network-kernel/network_host_parameters/sysctl_net_ipv4_conf_default_send_redirects/rule.yml",
"linux_os/guide/system/network/network-uncommon/kernel_module_tipc_disabled/rule.yml",
"linux_os/guide/system/permissions/files/dir_perms_world_writable_sticky_bits/rule.yml",
"linux_os/guide/system/permissions/mounting/kernel_module_cramfs_disabled/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_dev_shm_nodev/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_dev_shm_noexec/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_dev_shm_nosuid/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_nodev_removable_partitions/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_nosuid_removable_partitions/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_tmp_nodev/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_tmp_noexec/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_tmp_nosuid/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_var_tmp_nodev/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_var_tmp_noexec/rule.yml",
"linux_os/guide/system/permissions/partitions/mount_option_var_tmp_nosuid/rule.yml",
"linux_os/guide/system/permissions/restrictions/coredumps/disable_users_coredumps/rule.yml",
"linux_os/guide/system/permissions/restrictions/enable_execshield_settings/sysctl_kernel_randomize_va_space/rule.yml",
"linux_os/guide/system/software/disk_partitioning/partition_for_tmp/rule.yml",
"linux_os/guide/system/software/disk_partitioning/partition_for_var/rule.yml",
"linux_os/guide/system/software/disk_partitioning/partition_for_var_log/rule.yml",
"linux_os/guide/system/software/disk_partitioning/partition_for_var_log_audit/rule.yml",
"linux_os/guide/system/software/gnome/gnome_login_screen/dconf_gnome_disable_restart_shutdown/rule.yml",
"linux_os/guide/system/software/gnome/gnome_login_screen/gnome_gdm_disable_automatic_login/rule.yml",
"linux_os/guide/system/software/gnome/gnome_media_settings/dconf_gnome_disable_automount_open/rule.yml",
"linux_os/guide/system/software/gnome/gnome_screen_locking/dconf_gnome_screensaver_idle_delay/rule.yml",
"linux_os/guide/system/software/gnome/gnome_screen_locking/dconf_gnome_screensaver_lock_enabled/rule.yml",
"linux_os/guide/system/software/gnome/gnome_screen_locking/dconf_gnome_screensaver_mode_blank/rule.yml",
"linux_os/guide/system/software/gnome/gnome_screen_locking/dconf_gnome_session_idle_user_locks/rule.yml",
"linux_os/guide/system/software/gnome/gnome_system_settings/dconf_gnome_disable_ctrlaltdel_reboot/rule.yml",
"linux_os/guide/system/software/integrity/software-integrity/aide/aide_use_fips_hashes/rule.yml",
"linux_os/guide/system/software/updating/clean_components_post_updating/rule.yml",
"linux_os/guide/system/software/updating/ensure_gpgcheck_globally_activated/rule.yml",
]
    for path in paths:
        offending_lines = list()
        with open(path, 'r') as fp:
            lines = fp.readlines()
        for idx, line in enumerate(lines):
            if re.match(r'\s+disa:', line):
                offending_lines.append(idx)
        if len(offending_lines) == 2:
            del lines[offending_lines[0]]
            pprint(offending_lines)
            with open(path, 'w') as fp:
                fp.writelines(lines)
