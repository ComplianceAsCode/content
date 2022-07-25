documentation_complete: true

metadata:
    SMEs:
        - abergmann

title: 'ANSSI-BP-028 (intermediary)'

description: |-
    This profile contains configurations that align to ANSSI-BP-028 v1.2 at the intermediary hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    Only the components strictly necessary to the service provided by the system should be installed.
    Those whose presence can not be justified should be disabled, removed or deleted.
    Performing a minimal install is a good starting point, but doesn't provide any assurance
    over any package installed later.
    Manual review is required to assess if the installed services are minimal.

selections:
  - anssi_sle:all:intermediary
  - dir_perms_world_writable_root_owned
  - dir_perms_world_writable_sticky_bits
  - file_permissions_etc_shadow
  - file_permissions_unauthorized_world_writable
  - mount_option_nodev_nonroot_local_partitions
  - sysctl_kernel_exec_shield
  - sysctl_kernel_kptr_restrict
  - sysctl_kernel_randomize_va_space
  - sysctl_net_ipv4_conf_default_accept_redirects
  - sysctl_net_ipv4_conf_default_rp_filter
