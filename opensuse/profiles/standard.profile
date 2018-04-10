documentation_complete: true

title: 'Standard System Security Profile for OpenSUSE'

description: |-
    This profile contains rules to ensure standard security baseline
    of an OpenSUSE system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd
