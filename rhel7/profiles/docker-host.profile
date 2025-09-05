documentation_complete: false

title: 'DRAFT - Standard Docker Host Security Profile'

description: |-
    This profile contains rules to ensure standard security
    baseline of Red Hat Enterprise Linux 7 system running docker.

    This discussion is currently being held on open-scap-list@redhat.com
    and scap-security-guide@lists.fedorahosted.org.

selections:
    - package_docker_installed
    - service_docker_enabled
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
    - grub2_enable_selinux
    - selinux_state
    - selinux_policytype
    - docker_selinux_enabled
    - docker_storage_configured
