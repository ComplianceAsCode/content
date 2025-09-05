documentation_complete: true

title: 'Standard System Security Profile for openSUSE'

description: |-
    This profile contains rules to ensure standard security baseline
    of an openSUSE system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - file_owner_etc_passwd
    - file_groupowner_etc_passwd
    - file_permissions_etc_passwd
