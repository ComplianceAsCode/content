documentation_complete: true

title: 'Standard Docker Host Security Profile'

description: "This profile contains rules to ensure standard security baseline\nof Red Hat Enterprise Linux 7 system running\
    \ the docker daemon. This discussion\nis currently being held on open-scap-list@redhat.com and \nscap-security-guide@lists.fedorahosted.org."

selections:
    - service_docker_enabled
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
    - enable_selinux_bootloader
    - selinux_state
    - selinux_policytype
    - docker_selinux_enabled
    - docker_storage_configured
