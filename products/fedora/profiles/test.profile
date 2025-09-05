documentation_complete: false

metadata:
    version: 1
    SMEs:
        - mab879

title: 'Automatus Testing Profile'


description: |-
    This profile contains a few rules used to test Automatus in profile and combined modes.
    This profile is testing only and should not be shipped.

selections:
    - package_tmux_installed
    - file_groupowner_etc_passwd
