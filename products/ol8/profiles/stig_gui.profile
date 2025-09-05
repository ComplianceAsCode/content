documentation_complete: true

metadata:
    version: V2R3

title: 'DISA STIG with GUI for Oracle Linux 8'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG with GUI for Oracle Linux V2R3.

    Warning: The installation and use of a Graphical User Interface (GUI)
    increases your attack vector and decreases your overall security posture. If
    your Information Systems Security Officer (ISSO) lacks a documented operational
    requirement for a graphical user interface, please consider using the
    standard DISA STIG for Oracle Linux 8 profile.

extends: stig

selections:
    - '!xwindows_remove_packages'
    - '!xwindows_runlevel_target'

    # OL08-00-040284
    # Limiting user namespaces cause issues with user apps, such as Firefox and Cheese
    - '!sysctl_user_max_user_namespaces'

    # locking of idle sessions is handled by screensaver when GUI is present, the following rule is therefore redundant
    - '!logind_session_timeout'
