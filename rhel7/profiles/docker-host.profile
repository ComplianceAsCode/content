documentation_complete: false

title: 'DRAFT - Standard Docker Host Security Profile'

description: "This profile contains rules to ensure standard security \n
    \ baseline of Red Hat Enterprise Linux 7 system running the docker \n
    \ \n
    \ This discussion is currently being held on open-scap-list@redhat.com \n
    \ and scap-security-guide@lists.fedorahosted.org."

selections:
    - service_docker_enabled
    - var_selinux_policy_name=targeted
    - var_selinux_state=enforcing
    - grub2_enable_selinux
    - selinux_state
    - selinux_policytype
    - docker_selinux_enabled
    - docker_storage_configured
