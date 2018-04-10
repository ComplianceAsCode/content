documentation_complete: true

title: 'Desktop Baseline'

description: "This profile is for a desktop installation of \nRed Hat Enterprise Linux 6."

extends: standard

selections:
    - gconf_gdm_enable_warning_gui_banner
    - gconf_gdm_set_login_banner_text
    - gconf_gnome_screensaver_idle_delay
    - gconf_gnome_screensaver_idle_activation_enabled
    - gconf_gnome_screensaver_lock_enabled
    - gconf_gnome_screensaver_mode_blank
    - package_openswan_installed
    - service_vsftpd_disabled
    - package_vsftpd_removed
    - service_named_disabled
    - package_bind_removed
    - service_httpd_disabled
    - package_httpd_removed
    - service_smb_disabled
    - service_squid_disabled
    - package_squid_removed
    - service_snmpd_disabled
    - package_net-snmp_removed
    - service_dovecot_disabled
    - package_dovecot_removed
    - service_nfs_disabled
    - service_rpcsvcgssd_disabled
    - service_nfslock_disabled
    - service_rpcgssd_disabled
    - service_rpcidmapd_disabled
    - service_netfs_disabled
    - service_dhcpd_disabled
    - package_dhcp_removed
    - inactivity_timeout_value=15_minutes
