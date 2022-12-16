documentation_complete: true

title: 'CIS Ubuntu 22.04 Level 1 Workstation Benchmark'

description: |-
    This baseline aligns to the Center for Internet Security
    Ubuntu 22.04 LTS Benchmark, v1.0.0, released 08-30-2022.

extends: cis_level1_server

selections:
    ### 1.1.9 Disable Automounting (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!service_autofs_disabled'

    ### 1.1.10 Disable USB Storage (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!kernel_module_usb-storage_disabled'

    ### 1.8.6 Ensure GDM automatic mounting of removable media is disabled (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!dconf_gnome_disable_automount'
    - '!dconf_gnome_disable_automount_open'

    ### 1.8.7 Ensure GDM disabling automatic mounting of removable media is not overridden (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    # SAME AS ABOVE?

    ### 2.2.1 Ensure X Window System is not installed (Automated)
    # Skip due to being server-only.
    - '!package_xorg-x11-server-common_removed'

    ### 2.2.3 Ensure CUPS is not installed (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!service_cups_disabled'
    # - '!package_cups_removed'

    ### 3.1.2 Ensure wireless interfaces are disabled (Automated)
    # Skip due to being Level 1 Server and Level 2 Workstation.
    - '!wireless_disable_interfaces'

    ### 5.2.12 Ensure SSH X11 forwarding is disabled (Automated)
    - sshd_disable_x11_forwarding
