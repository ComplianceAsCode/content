documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt
        - vojtapolasek

title: 'ANSSI-BP-028 (high)'

description: |-
    This is a draft profile for experimental purposes.
    This draft profile contains configurations that align to ANSSI-BP-028 v2.0 at the high hardening level.

    ANSSI is the French National Information Security Agency, and stands for Agence nationale de la sécurité des systèmes d'information.
    ANSSI-BP-028 is a configuration recommendation for GNU/Linux systems.

    A copy of the ANSSI-BP-028 can be found at the ANSSI website:
    https://www.ssi.gouv.fr/administration/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux/

    An English version of the ANSSI-BP-028 can also be found at the ANSSI website:
    https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system

selections:
    - anssi:all:high
    - var_password_hashing_algorithm_pam=yescrypt
    # the following rule renders UEFI systems unbootable
    - 'service_chronyd_enabled'
    # RHEL 10 unified the paths for grub2 files. These rules are selected in control file by R29.
    - audit_rules_mac_modification_etc_selinux
    # these rules are failing when they are remediated with Ansible, removing them temporarily until they are fixed
