documentation_complete: true

title: 'CIS Ubuntu 22.04 Level 1 Workstation Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 22.04 LTS Benchmark, v1.0.0, released 07-21-2020.

extends: cis_level1_server

selections:
    ### 1.1.23 Disable Automounting (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!service_autofs_disabled'

    ### 1.1.24 Disable USB Storage (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!kernel_module_usb-storage_disabled'

    ## 1.10 Ensure GDM is removed or login is configured (Automated)
    - '!package_gdm_removed'
    - enable_dconf_user_profile
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text
    - dconf_gnome_disable_user_list

    ### 2.2.2 Ensure X Window System is not installed (Automated)
    # Skip due to being server-only.
    - '!package_xorg-x11-server-common_removed'

    ### 2.2.4 Ensure CUPS is not installed (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!service_cups_disabled'
    # Needs rule: '!package_cups_removed'

    ### 3.1.2 Ensure wireless interfaces are disabled (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!wireless_disable_interfaces'

    ### 5.2.5 Ensure SSH X11 forwarding is disabled (Automated)
    - sshd_disable_x11_forwarding
