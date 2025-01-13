documentation_complete: true

title: 'Sample Security Profile for Linux-like OSes'

description: |-
    This profile is an sample for use in documentation and example content.
    The selected rules are standard and should pass quickly on most systems.

selections:
    - abcd-levels:all:medium
    - file_groupownership_sshd_private_key
    - sshd_set_keepalive
    - var_sshd_set_keepalive=1
