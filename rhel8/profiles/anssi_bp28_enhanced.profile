documentation_complete: true

title: 'ANSSI BP-028 (enhanced)'

description: 
    ANSSI BP-028 compliance at the enhanced level. ANSSI stands for
    Agence nationale de la sécurité des systèmes d'information. Based on
    https://www.ssi.gouv.fr/.

extends: anssi_bp28_intermediary

selections:
    # Principle of least privilege

    # Network services partitioning

    # Logging of service activity

    # Access Restrictions on /boot directory
    - file_permissions_systemmap

    # Hardened package repositories

    # Boot loader password
    - grub2_password
    - grub2_uefi_password

    # Installation of secret or trusted elements

    # Disabling the loading of kernel modules
    # kernel.modules_disabled = 1

    # Yama module sysctl configuration
    - sysctl_kernel_yama_ptrace_scope

    # Uniqueness and exclusivity of system service accounts

    # User session timeout
    - accounts_tmout
    - sshd_set_idle_timeout
    - sshd_idle_timeout_value=5_minutes
    - sshd_set_keepalive

    # umask value
    - var_accounts_user_umask=077
    - accounts_umask_etc_login_defs
    - accounts_umask_etc_profile

    # Executable setuid root
    - file_permissions_unauthorized_suid
    - file_permissions_unauthorized_sgid

    # Logging activity by auditd

    # Restricting access of deployed services

    # Virtualization components hardening

    # Limiting the number of commands requiring the use of the EXEC option
